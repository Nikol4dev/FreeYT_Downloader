package com.example.premium_downloader

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ContentValues
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.MediaStore
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import java.io.File
import java.io.IOException
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors

class DownloadForegroundService : Service() {

    companion object {
        const val ACTION_START = "com.example.premium_downloader.START"
        const val ACTION_CANCEL = "com.example.premium_downloader.CANCEL"
        const val EXTRA_TASK_ID = "taskId"
        const val EXTRA_URL = "url"
        const val EXTRA_TITLE = "title"
        const val EXTRA_QUALITY = "quality"
        const val EXTRA_FOLDER = "folder"

        private const val CH_PROGRESS = "downloads_progress"
        private const val CH_RESULT = "downloads_result"
        private const val FG_ID = 1001
        private const val MAX_PARALLEL = 3
        private val SPEED = Regex("at\\s+([\\d.]+\\s*[KMG]?i?B/s)")
        private val MEDIA_EXT = setOf("mp4", "mkv", "webm", "m4a", "mp3", "opus", "aac", "ogg")
    }

    private val executor = Executors.newFixedThreadPool(MAX_PARALLEL)
    private val active: MutableSet<String> = ConcurrentHashMap.newKeySet()
    private val main = Handler(Looper.getMainLooper())

    override fun onCreate() {
        super.onCreate()
        createChannels()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                showForeground()
                val id = intent.getStringExtra(EXTRA_TASK_ID)
                val url = intent.getStringExtra(EXTRA_URL)
                if (id == null || url == null) {
                    scheduleIdleCheck()
                    return START_NOT_STICKY
                }
                val title = intent.getStringExtra(EXTRA_TITLE) ?: "Video"
                val quality = intent.getStringExtra(EXTRA_QUALITY) ?: "Best"
                val folder = intent.getStringExtra(EXTRA_FOLDER) ?: ""
                if (active.add(id)) {
                    YtDlpEngine.cancelled.remove(id)
                    showForeground()
                    executor.execute { runDownload(id, url, title, quality, folder, android.os.Bundle(intent.extras ?: android.os.Bundle())) }
                }
            }
            ACTION_CANCEL -> intent.getStringExtra(EXTRA_TASK_ID)?.let { YtDlpEngine.requestCancel(it) }
        }
        return START_NOT_STICKY
    }

    private fun runDownload(taskId: String, url: String, title: String, quality: String, folder: String, opts: android.os.Bundle) {
        val notifId = taskId.hashCode()
        val nm = getSystemService(NotificationManager::class.java)
        val workDir = File(getExternalFilesDir(null), "TempDownloads/$taskId").apply { mkdirs() }
        val isAudio = quality.startsWith("Audio", ignoreCase = true)

        try {
            YtDlpEngine.ensureInit(this)
            emit(taskId, "downloading", 0.0)
            nm.notify(notifId, progressNotification(taskId, title, 0))

            val tracker = ProgressTracker(if (isAudio) 1 else 2)
            var lastPct = -1

            YoutubeDL.getInstance().execute(buildRequest(url, workDir, quality, isAudio, opts), taskId) { p, eta, line ->
                val overall = tracker.update(p)
                val pct = (overall * 100).toInt()
                if (pct != lastPct) {
                    lastPct = pct
                    nm.notify(notifId, progressNotification(taskId, title, pct))
                    emit(taskId, "downloading", overall.toDouble(), mapOf("eta" to eta, "speed" to (SPEED.find(line)?.groupValues?.get(1) ?: "")))
                }
            }

            val output = workDir.listFiles()
                ?.filter { it.isFile && it.extension.lowercase() in MEDIA_EXT }
                ?.maxByOrNull { it.length() }
                ?: throw IllegalStateException("Download finished but no output file was found")

            val (uri, size) = saveToMediaStore(output, title, isAudio, folder)
            workDir.deleteRecursively()

            nm.notify(notifId, resultNotification(title, "Download complete", ok = true))
            emit(taskId, "success", 1.0, mapOf("uri" to uri, "sizeBytes" to size))
        } catch (e: Exception) {
            if (YtDlpEngine.paused.remove(taskId)) {
                nm.cancel(notifId)
                emit(taskId, "paused")
            } else if (YtDlpEngine.cancelled.remove(taskId)) {
                workDir.deleteRecursively()
                nm.cancel(notifId)
                emit(taskId, "cancelled")
            } else {
                nm.notify(notifId, resultNotification(title, "Download failed", ok = false))
                emit(taskId, "error", 0.0, mapOf("message" to (e.message ?: e.toString())))
            }
        } finally {
            active.remove(taskId)
            showForegroundIfActive()
            scheduleIdleCheck()
        }
    }

    private fun buildRequest(url: String, dir: File, quality: String, isAudio: Boolean, opts: android.os.Bundle) =
        YoutubeDLRequest(url).apply {
            addOption("--no-playlist")
            addOption("-o", "${dir.absolutePath}/%(id)s.%(ext)s")
            addOption("--continue")
            addOption("--no-mtime")
            addOption("--socket-timeout", "20")
            addOption("--retries", "10")
            addOption("--fragment-retries", "10")
            addOption("--concurrent-fragments", "4")
            addOption("--embed-metadata")
            opts.getString("section")?.takeIf { it.isNotBlank() }?.let {
                addOption("--download-sections", it)
                if (opts.getBoolean("exactCut")) addOption("--force-keyframes-at-cuts")
            }
            if (opts.getBoolean("sponsorBlock")) addOption("--sponsorblock-remove", "sponsor,selfpromo")
            if (!isAudio && opts.getBoolean("subtitles")) {
                addOption("--write-subs")
                addOption("--write-auto-subs")
                addOption("--sub-langs", opts.getString("subLangs") ?: "en")
                addOption("--embed-subs")
            }
            if (isAudio) {
                addOption("-f", "bestaudio[ext=m4a]/bestaudio/best")
                addOption("-x")
                addOption("--audio-format", if (quality.contains("MP3", true)) "mp3" else "m4a")
                addOption("--audio-quality", "0")
            } else {
                val h = quality.filter { it.isDigit() }
                val cap = if (h.isEmpty()) "" else "[height<=$h]"
                addOption("-f", "bv*$cap[ext=mp4]+ba[ext=m4a]/bv*$cap+ba/b$cap")
                addOption("--merge-output-format", "mp4")
            }
        }

    
    // Video and audio download as separate passes; fold them into one bar.
    private class ProgressTracker(private val phases: Int) {
        private var phase = 0
        private var last = 0f
        private var best = 0f

        fun update(p: Float): Float {
            if (p < 0f) return best
            if (p + 30f < last) phase = (phase + 1).coerceAtMost(phases - 1)
            last = p
            val overall = (phase * 100f + p) / (phases * 100f)
            best = maxOf(best, overall.coerceIn(0f, 0.99f))
            return best
        }
    }

    private fun saveToMediaStore(src: File, title: String, isAudio: Boolean, folder: String): Pair<String, Long> {
        val ext = src.extension.lowercase()
        val name = sanitize(title).ifBlank { src.nameWithoutExtension } + "." + ext
        val size = src.length()
        val mime = when (ext) {
            "mp3" -> "audio/mpeg"
            "m4a", "aac" -> "audio/mp4"
            "opus", "ogg" -> "audio/ogg"
            "webm" -> if (isAudio) "audio/webm" else "video/webm"
            "mkv" -> "video/x-matroska"
            else -> if (isAudio) "audio/mp4" else "video/mp4"
        }
        val baseDir = if (isAudio) Environment.DIRECTORY_MUSIC else Environment.DIRECTORY_MOVIES
        val sub = sanitize(folder).ifBlank { "Downloader" }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val collection = if (isAudio) MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            else MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                put(MediaStore.MediaColumns.MIME_TYPE, mime)
                put(MediaStore.MediaColumns.RELATIVE_PATH, "$baseDir/$sub")
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri = contentResolver.insert(collection, values) ?: throw IOException("MediaStore insert failed")
            try {
                val out = contentResolver.openOutputStream(uri) ?: throw IOException("Cannot open output stream")
                out.use { o -> src.inputStream().use { it.copyTo(o, 256 * 1024) } }
                contentResolver.update(uri, ContentValues().apply { put(MediaStore.MediaColumns.IS_PENDING, 0) }, null, null)
            } catch (e: Exception) {
                contentResolver.delete(uri, null, null)
                throw e
            }
            return uri.toString() to size
        }

        val dir = File(Environment.getExternalStoragePublicDirectory(baseDir), sub).apply { mkdirs() }
        var dest = File(dir, name)
        var n = 1
        while (dest.exists()) dest = File(dir, "${sanitize(title)} ($n++).$ext")
        src.copyTo(dest)
        MediaScannerConnection.scanFile(this, arrayOf(dest.absolutePath), arrayOf(mime), null)
        return Uri.fromFile(dest).toString() to size
    }

    private fun sanitize(s: String) =
        s.replace(Regex("[\\\\/:*?\"<>|\\p{Cntrl}]"), "_").replace(Regex("\\s+"), " ").trim().take(120)

    private fun emit(taskId: String, status: String, progress: Double = 0.0, extra: Map<String, Any?> = emptyMap()) {
        DownloadEvents.emit(mapOf("taskId" to taskId, "status" to status, "progress" to progress) + extra)
    }

    private fun showForeground() {
        val n = NotificationCompat.Builder(this, CH_PROGRESS)
            .setContentTitle("Downloading")
            .setContentText("${active.size.coerceAtLeast(1)} active download(s)")
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(openAppIntent())
            .build()
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC else 0
        ServiceCompat.startForeground(this, FG_ID, n, type)
    }

    private fun showForegroundIfActive() {
        if (active.isNotEmpty()) main.post { if (active.isNotEmpty()) showForeground() }
    }

    
    private fun scheduleIdleCheck() {
        main.post {
            if (active.isEmpty()) {
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
    }

    private fun progressNotification(taskId: String, title: String, pct: Int): Notification {
        val cancel = PendingIntent.getService(
            this, taskId.hashCode(),
            Intent(this, DownloadForegroundService::class.java).setAction(ACTION_CANCEL).putExtra(EXTRA_TASK_ID, taskId),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        return NotificationCompat.Builder(this, CH_PROGRESS)
            .setContentTitle(title)
            .setContentText(if (pct <= 0) "Starting…" else "$pct%")
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setProgress(100, pct, pct <= 0)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(openAppIntent())
            .addAction(0, "Cancel", cancel)
            .build()
    }

    private fun resultNotification(title: String, text: String, ok: Boolean): Notification =
        NotificationCompat.Builder(this, CH_RESULT)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(if (ok) android.R.drawable.stat_sys_download_done else android.R.drawable.stat_notify_error)
            .setAutoCancel(true)
            .setContentIntent(openAppIntent())
            .build()

    private fun openAppIntent(): PendingIntent? =
        packageManager.getLaunchIntentForPackage(packageName)?.let {
            PendingIntent.getActivity(this, 0, it, PendingIntent.FLAG_IMMUTABLE)
        }

    private fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(NotificationChannel(CH_PROGRESS, "Active downloads", NotificationManager.IMPORTANCE_LOW))
        nm.createNotificationChannel(NotificationChannel(CH_RESULT, "Download results", NotificationManager.IMPORTANCE_DEFAULT))
    }

    override fun onDestroy() {
        executor.shutdownNow()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
