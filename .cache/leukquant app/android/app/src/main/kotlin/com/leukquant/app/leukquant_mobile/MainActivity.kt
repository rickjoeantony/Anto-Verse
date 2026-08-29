package com.leukquant.app.leukquant_mobile

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.RingtoneManager
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.leukquant.app/audio_alerts"
    private val NOTIF_CHANNEL_ID = "leukquant_threat_telemetry_v10"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createHighPriorityNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playAlertTone" -> {
                    val toneType = call.argument<String>("type") ?: "cyberRadar"
                    playNativeAlertTone(toneType)
                    result.success(true)
                }
                "postAlertNotification" -> {
                    val title = call.argument<String>("title") ?: "âš¡ Critical Attack Detected"
                    val body = call.argument<String>("body") ?: "Unauthorized decoy ingress detected."
                    val notifId = call.argument<Int>("id") ?: 99991
                    postNativeNotification(notifId, title, body)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun createHighPriorityNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION_EVENT)
                .build()

            val channel = NotificationChannel(
                NOTIF_CHANNEL_ID,
                "LeukQuant Critical Ingress Telemetry",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Audible high-priority alerts for honeypot intrusions and canary access."
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 300, 150, 300)
                setSound(soundUri, audioAttributes)
                enableLights(true)
                setShowBadge(true)
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun playNativeAlertTone(type: String) {
        try {
            // 1. Play loud audible system ringtone
            val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val ringtone = RingtoneManager.getRingtone(applicationContext, ringtoneUri)
            ringtone?.play()

            // 2. Play acoustic synthesizer tone based on tone type
            val toneType = when (type.lowercase()) {
                "cyberradar" -> ToneGenerator.TONE_CDMA_EMERGENCY_RINGBACK
                "tacticalpulse" -> ToneGenerator.TONE_PROP_BEEP2
                "enterpriseping" -> ToneGenerator.TONE_PROP_ACK
                else -> ToneGenerator.TONE_PROP_BEEP
            }

            try {
                val toneGen = ToneGenerator(AudioManager.STREAM_ALARM, 100)
                toneGen.startTone(toneType, 350)
            } catch (_: Exception) {}

            // 3. Trigger hardware vibration
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                val vibrator = vibratorManager.defaultVibrator
                vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 250, 100, 250), -1))
            } else {
                @Suppress("DEPRECATION")
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 250, 100, 250), -1))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(longArrayOf(0, 250, 100, 250), -1)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun postNativeNotification(id: Int, title: String, body: String) {
        try {
            val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val builder = NotificationCompat.Builder(this, NOTIF_CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setSound(soundUri)
                .setVibrate(longArrayOf(0, 300, 150, 300))
                .setAutoCancel(true)

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(id, builder.build())

            // Also play loud native audio tone
            playNativeAlertTone("cyberRadar")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}