package com.prismforge.app

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val storageChannelName = "com.prismforge/storage"
    private val audioChannelName = "com.prismforge/audio"
    private val prefsName = "prism_forge_progress"
    private val audioExecutor = Executors.newCachedThreadPool()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 1. Offline local progress storage (SharedPreferences — zero permissions).
        val prefs = applicationContext.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        MethodChannel(messenger, storageChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "read" -> {
                    val key = call.argument<String>("key")
                    if (key == null) {
                        result.error("INVALID_ARGS", "Missing key", null)
                    } else {
                        result.success(prefs.getString(key, null))
                    }
                }
                "write" -> {
                    val key = call.argument<String>("key")
                    val value = call.argument<String>("value")
                    if (key == null || value == null) {
                        result.error("INVALID_ARGS", "Missing key or value", null)
                    } else {
                        prefs.edit().putString(key, value).apply()
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 2. Offline procedural PCM playback (AudioTrack — zero permissions).
        MethodChannel(messenger, audioChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "playPcm" -> {
                    val pcm = call.argument<ByteArray>("pcm")
                    val sampleRate = call.argument<Int>("sampleRate") ?: 22050
                    if (pcm == null || pcm.isEmpty()) {
                        result.success(null)
                    } else {
                        playPcmAsync(pcm, sampleRate)
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playPcmAsync(pcm: ByteArray, sampleRate: Int) {
        audioExecutor.execute {
            var track: AudioTrack? = null
            try {
                val minBuf = AudioTrack.getMinBufferSize(
                    sampleRate,
                    AudioFormat.CHANNEL_OUT_MONO,
                    AudioFormat.ENCODING_PCM_16BIT
                ).coerceAtLeast(pcm.size)

                track = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_GAME)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(minBuf)
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()

                track.write(pcm, 0, pcm.size)
                track.play()
                val durationMs = ((pcm.size / 2.0) / sampleRate * 1000.0).toLong() + 60L
                Thread.sleep(durationMs)
            } catch (_: Throwable) {
                // Gracefully ignore audio focus / headless playback errors.
            } finally {
                try {
                    track?.stop()
                    track?.release()
                } catch (_: Throwable) {
                }
            }
        }
    }
}
