package com.example.premium_downloader

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.yausername.ffmpeg.FFmpeg
import com.yausername.youtubedl_android.YoutubeDL
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.ConcurrentHashMap

object YtDlpEngine {
    @Volatile private var ready = false

    
    val cancelled: MutableSet<String> = ConcurrentHashMap.newKeySet()
    val paused: MutableSet<String> = ConcurrentHashMap.newKeySet()

    @Synchronized
    fun ensureInit(context: Context) {
        if (ready) return
        val app = context.applicationContext
        YoutubeDL.getInstance().init(app)
        FFmpeg.getInstance().init(app)
        ready = true
    }

    fun requestCancel(taskId: String): Boolean {
        cancelled.add(taskId)
        return try {
            YoutubeDL.getInstance().destroyProcessById(taskId)
        } catch (e: Exception) {
            false
        }
    }
}

// Holds the last event per task until Flutter acknowledges it, so nothing is lost while the UI is closed.
object DownloadEvents {
    private val main = Handler(Looper.getMainLooper())
    private val latest = ConcurrentHashMap<String, Map<String, Any?>>()
    @Volatile private var sink: EventChannel.EventSink? = null

    fun emit(event: Map<String, Any?>) {
        val id = event["taskId"] as? String ?: return
        latest[id] = event
        main.post { sink?.success(event) }
    }

    fun attach(newSink: EventChannel.EventSink?) {
        sink = newSink
        newSink ?: return
        main.post { latest.values.toList().forEach { newSink.success(it) } }
    }

    fun detach() {
        sink = null
    }

    fun ack(taskId: String) {
        latest.remove(taskId)
    }
}
