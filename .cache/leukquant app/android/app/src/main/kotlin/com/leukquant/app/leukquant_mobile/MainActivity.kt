package com.leukquant.app.leukquant_mobile

import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.RingtoneManager
import android.media.ToneGenerator
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.view.WindowManager
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.leukquant.app/audio_alerts"
    private val NOTIF_CRITICAL_CHANNEL_ID = "leukquant_critical_telemetry_v11"
    private val NOTIF_MEDIUM_CHANNEL_ID = "leukquant_medium_telemetry_v11"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        unlockAndTurnScreenOn()
    }

    private fun unlockAndTurnScreenOn() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createNotificationChannels()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playAlertTone" -> {
                    val toneType = call.argument<String>("type") ?: "cyberRadar"
                    playNativeAlertTone(toneType)
                    result.success(true)
                }
                "postAlertNotification" -> {
                    val title = call.argument<String>("title") ?: "⚡ Security Alert Detected"
                    val body = call.argument<String>("body") ?: "Decoy sensor activity detected."
                    val notifId = call.argument<Int>("id") ?: 99991
                    val isCritical = call.argument<Boolean>("isCritical") ?: true
                    val severity = call.argument<String>("severity") ?: "high"
                    postNativeNotification(notifId, title, body, isCritical, severity)
                    result.success(true)
                }
                "openNotificationSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (_: Exception) {
                        val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(fallback)
                        result.success(true)
                    }
                }
                "openBatterySettings" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                        } else {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                        }
                        result.success(true)
                    } catch (_: Exception) {
                        try {
                            val fallback = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(fallback)
                            result.success(true)
                        } catch (_: Exception) {
                            val appDetails = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(appDetails)
                            result.success(true)
                        }
                    }
                }
                "openFullScreenSettings" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= 34) { // Android 14+
                            val intent = Intent("android.settings.MANAGE_APP_USE_FULL_SCREEN_INTENT").apply {
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                        } else {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                        }
                        result.success(true)
                    } catch (_: Exception) {
                        val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(fallback)
                        result.success(true)
                    }
                }
                "isBatteryOptimizationIgnored" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                            val isIgnored = powerManager.isIgnoringBatteryOptimizations(packageName)
                            result.success(isIgnored)
                        } else {
                            result.success(true)
                        }
                    } catch (_: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val alarmSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val notifSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

            val alarmAudioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_ALARM)
                .build()

            val notifAudioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()

            // 1. Critical & High Alert Channel
            val criticalChannel = NotificationChannel(
                NOTIF_CRITICAL_CHANNEL_ID,
                "🚨 Critical & High Telemetry Ingress",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Loud audible alarm alerts for Critical and High risk honeypot intrusions and canary breaches."
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500, 200, 500)
                setSound(alarmSoundUri, alarmAudioAttributes)
                enableLights(true)
                lightColor = android.graphics.Color.RED
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setBypassDnd(true)
            }

            // 2. Medium Alert Channel
            val mediumChannel = NotificationChannel(
                NOTIF_MEDIUM_CHANNEL_ID,
                "🔶 Medium-Risk Telemetry Ingress",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Immediate alerts for Medium risk decoy reconnaissance, port scans, and telemetry spikes."
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 300, 150, 300)
                setSound(notifSoundUri, notifAudioAttributes)
                enableLights(true)
                lightColor = android.graphics.Color.YELLOW
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(criticalChannel)
            manager.createNotificationChannel(mediumChannel)
        }
    }

    private fun playNativeAlertTone(type: String) {
        try {
            val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val ringtone = RingtoneManager.getRingtone(applicationContext, ringtoneUri)
            ringtone?.play()

            val toneType = when (type.lowercase()) {
                "cyberradar" -> ToneGenerator.TONE_CDMA_EMERGENCY_RINGBACK
                "tacticalpulse" -> ToneGenerator.TONE_PROP_BEEP2
                "enterpriseping" -> ToneGenerator.TONE_PROP_ACK
                else -> ToneGenerator.TONE_PROP_BEEP
            }

            try {
                val toneGen = ToneGenerator(AudioManager.STREAM_ALARM, 100)
                toneGen.startTone(toneType, 500)
            } catch (_: Exception) {}

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                val vibrator = vibratorManager.defaultVibrator
                vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 500, 200, 500), -1))
            } else {
                @Suppress("DEPRECATION")
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 500, 200, 500), -1))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(longArrayOf(0, 500, 200, 500, 200, 500), -1)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun postNativeNotification(id: Int, title: String, body: String, isCritical: Boolean, severity: String) {
        try {
            // 1. Wake up the locked screen immediately
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            @Suppress("DEPRECATION")
            val wakeLock = powerManager.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
                "leukquant:attack_alert_wake"
            )
            wakeLock.acquire(10000)

            // 2. Full-Screen & Lock-Screen Intent
            val notifyIntent = Intent(applicationContext, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                action = "ACTION_CRITICAL_ALERT"
                putExtra("alert_id", id)
            }
            val pendingIntent = PendingIntent.getActivity(
                applicationContext,
                id,
                notifyIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )

            val channelId = if (isCritical || severity.equals("critical", true) || severity.equals("high", true)) {
                NOTIF_CRITICAL_CHANNEL_ID
            } else {
                NOTIF_MEDIUM_CHANNEL_ID
            }

            val soundUri = if (isCritical) {
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            } else {
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            }

            val vibrationPattern = if (isCritical) {
                longArrayOf(0, 500, 200, 500, 200, 500)
            } else {
                longArrayOf(0, 300, 150, 300)
            }

            val builder = NotificationCompat.Builder(applicationContext, channelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setSound(soundUri)
                .setVibrate(vibrationPattern)
                .setFullScreenIntent(pendingIntent, true)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(id, builder.build())

            // 3. Play audible tone
            playNativeAlertTone(if (isCritical) "cyberRadar" else "enterprisePing")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}