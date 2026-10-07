package com.example.premium_downloader

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {
    private val methodChannelName = "com.premium.downloader/ytdlp"
    private val eventChannelName = "com.premium.downloader/progress"

    private val io = Executors.newCachedThreadPool()
    private var sharedText: String? = null
    private val main = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (android.os.Build.VERSION.SDK_INT >= 33 &&
            checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != android.content.pm.PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 1)
        }
        io.execute { try { YtDlpEngine.ensureInit(applicationContext) } catch (_: Exception) {} }
        handleShare(intent)
        publishShareShortcut()
    }

    // Adds the app to the Direct Share row of the share sheet.
    private fun publishShareShortcut() {
        try {
            val shortcut = androidx.core.content.pm.ShortcutInfoCompat.Builder(this, "share")
                .setShortLabel("Downloader")
                .setLongLived(true)
                .setIcon(androidx.core.graphics.drawable.IconCompat.createWithResource(this, R.mipmap.ic_launcher))
                .setIntent(Intent(this, MainActivity::class.java).setAction(Intent.ACTION_VIEW))
                .setCategories(setOf("com.example.premium_downloader.SHARE"))
                .build()
            androidx.core.content.pm.ShortcutManagerCompat.pushDynamicShortcut(this, shortcut)
        } catch (_: Exception) {
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleShare(intent)
    }

    private fun handleShare(intent: Intent?) {
        if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, methodChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "startDownload" -> {
                    val id = call.argument<String>("taskId")
                    val url = call.argument<String>("url")
                    if (id == null || url == null) {
                        result.error("BAD_ARGS", "taskId and url are required", null)
                    } else {
                        val intent = Intent(this, DownloadForegroundService::class.java).apply {
                            action = DownloadForegroundService.ACTION_START
                            putExtra(DownloadForegroundService.EXTRA_TASK_ID, id)
                            putExtra(DownloadForegroundService.EXTRA_URL, url)
                            putExtra(DownloadForegroundService.EXTRA_TITLE, call.argument<String>("title"))
                            putExtra(DownloadForegroundService.EXTRA_QUALITY, call.argument<String>("quality"))
                            putExtra(DownloadForegroundService.EXTRA_FOLDER, call.argument<String>("folder"))
                            putExtra("section", call.argument<String>("section"))
                            putExtra("exactCut", call.argument<Boolean>("exactCut") ?: false)
                            putExtra("subtitles", call.argument<Boolean>("subtitles") ?: false)
                            putExtra("subLangs", call.argument<String>("subLangs"))
                            putExtra("sponsorBlock", call.argument<Boolean>("sponsorBlock") ?: false)
                            putExtra("notify", call.argument<Boolean>("notify") ?: true)
                        }
                        ContextCompat.startForegroundService(this, intent)
                        result.success(true)
                    }
                }

                "scanFolder" -> {
                    if (android.os.Build.VERSION.SDK_INT < 29) {
                        result.success(emptyList<Any>())
                    } else {
                        val need = if (android.os.Build.VERSION.SDK_INT >= 33) {
                            arrayOf(android.Manifest.permission.READ_MEDIA_VIDEO, android.Manifest.permission.READ_MEDIA_AUDIO)
                        } else {
                            arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE)
                        }
                        if (need.any { checkSelfPermission(it) != android.content.pm.PackageManager.PERMISSION_GRANTED }) {
                            requestPermissions(need, 2)
                            result.success(null)
                        } else {
                            val sub = (call.argument<String>("folder") ?: "").replace(Regex("[\\\\/:*?\"<>|\\p{Cntrl}]"), "_").trim().ifBlank { "Downloader" }
                            io.execute {
                                val items = mutableListOf<Map<String, Any?>>()
                                val sources = listOf(
                                    Triple(android.provider.MediaStore.Video.Media.EXTERNAL_CONTENT_URI, android.os.Environment.DIRECTORY_MOVIES, false),
                                    Triple(android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, android.os.Environment.DIRECTORY_MUSIC, true)
                                )
                                for ((collection, base, audio) in sources) {
                                    try {
                                        contentResolver.query(
                                            collection,
                                            arrayOf(
                                                android.provider.MediaStore.MediaColumns._ID,
                                                android.provider.MediaStore.MediaColumns.DISPLAY_NAME,
                                                android.provider.MediaStore.MediaColumns.SIZE,
                                                android.provider.MediaStore.MediaColumns.DURATION
                                            ),
                                            "${android.provider.MediaStore.MediaColumns.RELATIVE_PATH} LIKE ?",
                                            arrayOf("$base/$sub/%"),
                                            null
                                        )?.use { c ->
                                            while (c.moveToNext()) {
                                                items.add(
                                                    mapOf(
                                                        "uri" to android.content.ContentUris.withAppendedId(collection, c.getLong(0)).toString(),
                                                        "name" to (c.getString(1) ?: "Video"),
                                                        "sizeBytes" to c.getLong(2),
                                                        "durationMs" to c.getLong(3),
                                                        "audio" to audio
                                                    )
                                                )
                                            }
                                        }
                                    } catch (_: Exception) {
                                    }
                                }
                                main.post { result.success(items) }
                            }
                        }
                    }
                }

                "openUrl" -> {
                    try {
                        startActivity(Intent(Intent.ACTION_VIEW, android.net.Uri.parse(call.argument<String>("url") ?: "")).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }

                "takeShared" -> {
                    result.success(sharedText)
                    sharedText = null
                }

                "isMetered" -> {
                    val cm = getSystemService(android.net.ConnectivityManager::class.java)
                    result.success(cm?.isActiveNetworkMetered ?: false)
                }

                "pauseDownload" -> {
                    val id = call.argument<String>("taskId")
                    if (id == null) {
                        result.error("BAD_ARGS", "taskId is required", null)
                    } else {
                        YtDlpEngine.paused.add(id)
                        val ok = try {
                            YoutubeDL.getInstance().destroyProcessById(id)
                        } catch (e: Exception) {
                            false
                        }
                        if (!ok) YtDlpEngine.paused.remove(id)
                        result.success(ok)
                    }
                }

                "cancelDownload" -> {
                    val id = call.argument<String>("taskId")
                    if (id == null) result.error("BAD_ARGS", "taskId is required", null)
                    else result.success(YtDlpEngine.requestCancel(id).also { if (!it) YtDlpEngine.cancelled.remove(id) })
                }

                "ackEvent" -> {
                    call.argument<String>("taskId")?.let { DownloadEvents.ack(it) }
                    result.success(null)
                }

                "previewUrl" -> {
                    val url = call.argument<String>("url")
                    if (url == null) {
                        result.error("BAD_ARGS", "url is required", null)
                    } else io.execute {
                        try {
                            YtDlpEngine.ensureInit(applicationContext)
                            val req = YoutubeDLRequest(url).apply {
                                addOption("--no-playlist")
                                addOption("-g")
                                addOption("-f", "18/best[height<=480][vcodec!=none][acodec!=none]/best[vcodec!=none][acodec!=none]")
                                addOption("--socket-timeout", "20")
                            }
                            val link = YoutubeDL.getInstance().execute(req).out.lines().map { it.trim() }.firstOrNull { it.startsWith("http") }
                                ?: throw IllegalStateException("No preview available")
                            main.post { result.success(link) }
                        } catch (e: Exception) {
                            main.post { result.error("PREVIEW_FAILED", e.message ?: e.toString(), null) }
                        }
                    }
                }

                "fetchPlaylist" -> {
                    val url = call.argument<String>("url")
                    if (url == null) {
                        result.error("BAD_ARGS", "url is required", null)
                    } else io.execute {
                        try {
                            YtDlpEngine.ensureInit(applicationContext)
                            val req = YoutubeDLRequest(url).apply {
                                addOption("--flat-playlist")
                                addOption("--dump-single-json")
                                addOption("--socket-timeout", "20")
                            }
                            val out = YoutubeDL.getInstance().execute(req).out
                            val json = org.json.JSONObject(out.substring(out.indexOf('{'), out.lastIndexOf('}') + 1))
                            val arr = json.optJSONArray("entries") ?: org.json.JSONArray()
                            val entries = (0 until arr.length()).mapNotNull { i ->
                                val e = arr.optJSONObject(i) ?: return@mapNotNull null
                                val id = if (e.isNull("id")) "" else e.optString("id")
                                if (id.length != 11) return@mapNotNull null
                                val channel = when {
                                    !e.isNull("uploader") -> e.optString("uploader")
                                    !e.isNull("channel") -> e.optString("channel")
                                    else -> ""
                                }
                                mapOf(
                                    "id" to id,
                                    "title" to (if (e.isNull("title")) "Untitled" else e.optString("title")),
                                    "channel" to channel,
                                    "durationSeconds" to e.optInt("duration", 0)
                                )
                            }
                            val data = mapOf("title" to (if (json.isNull("title")) "Playlist" else json.optString("title")), "entries" to entries)
                            main.post { result.success(data) }
                        } catch (e: Exception) {
                            main.post { result.error("FETCH_FAILED", e.message ?: e.toString(), null) }
                        }
                    }
                }

                "fetchInfo" -> {
                    val url = call.argument<String>("url")
                    if (url == null) {
                        result.error("BAD_ARGS", "url is required", null)
                    } else io.execute {
                        try {
                            YtDlpEngine.ensureInit(applicationContext)
                            val req = YoutubeDLRequest(url).apply {
                                addOption("--no-playlist")
                                addOption("--dump-single-json")
                                addOption("--socket-timeout", "20")
                            }
                            val out = YoutubeDL.getInstance().execute(req).out
                            val j = org.json.JSONObject(out.substring(out.indexOf('{'), out.lastIndexOf('}') + 1))
                            val formats = j.optJSONArray("formats") ?: org.json.JSONArray()
                            val heights = sortedSetOf<Int>()
                            val sizes = HashMap<String, Long>()
                            var audio = 0L
                            for (i in 0 until formats.length()) {
                                val f = formats.optJSONObject(i) ?: continue
                                val size = when {
                                    !f.isNull("filesize") -> f.optLong("filesize")
                                    !f.isNull("filesize_approx") -> f.optLong("filesize_approx")
                                    else -> 0L
                                }
                                val h = if (f.isNull("height")) 0 else f.optInt("height")
                                val video = !f.isNull("vcodec") && f.optString("vcodec") != "none"
                                val hasAudio = !f.isNull("acodec") && f.optString("acodec") != "none"
                                if (video && h > 0) {
                                    heights.add(h)
                                    if (size > (sizes["$h"] ?: 0L)) sizes["$h"] = size
                                } else if (!video && hasAudio && size > audio) {
                                    audio = size
                                }
                            }
                            fun str(k: String): String? = if (j.isNull(k)) null else j.optString(k)
                            val data = mapOf(
                                "id" to (str("id") ?: throw IllegalStateException("No video id returned")),
                                "title" to str("title"),
                                "channel" to (str("uploader") ?: str("channel")),
                                "durationSeconds" to j.optInt("duration", 0),
                                "thumbnail" to str("thumbnail"),
                                "heights" to heights.toList().sortedDescending(),
                                "sizes" to sizes,
                                "audioSize" to audio
                            )
                            main.post { result.success(data) }
                        } catch (e: Exception) {
                            main.post { result.error("FETCH_FAILED", e.message ?: e.toString(), null) }
                        }
                    }
                }

                "deleteFile" -> {
                    val u = android.net.Uri.parse(call.argument<String>("uri") ?: "")
                    try {
                        if (u.scheme == "file") java.io.File(u.path ?: "").delete()
                        else contentResolver.delete(u, null, null)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }

                "updateEngine" -> io.execute {
                    try {
                        YtDlpEngine.ensureInit(applicationContext)
                        val status = YoutubeDL.getInstance().updateYoutubeDL(applicationContext)
                        main.post { result.success(status?.name ?: "DONE") }
                    } catch (e: Exception) {
                        main.post { result.error("UPDATE_FAILED", e.message ?: e.toString(), null) }
                    }
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, eventChannelName).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) = DownloadEvents.attach(events)
            override fun onCancel(arguments: Any?) = DownloadEvents.detach()
        })
    }

    override fun onDestroy() {
        DownloadEvents.detach()
        io.shutdown()
        super.onDestroy()
    }
}
