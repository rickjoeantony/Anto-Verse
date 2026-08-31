package com.leukquant.app.leukquant_mobile

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.RingtoneManager
import android.media.ToneGenerator
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

/**
 * 24/7 Native Android Daemon Service for LeukQuant.
 *
 * Runs completely independent of the Flutter UI process.
 * Even when the user closes the app, kills it from Recent Apps, or turns on the phone in the morning,
 * this service continuously monitors https://api.leukquant.com/api/dashboard/events and triggers
 * loud audio alarms, screen wakeups, and high-priority lockscreen notifications for Medium & Critical attacks.
 */
class TelemetryBackgroundService : Service() {

    companion object {
        private const val CRITICAL_CHANNEL_ID = "leukquant_critical_telemetry_v11"
        private const val MEDIUM_CHANNEL_ID = "leukquant_medium_telemetry_v11"
        private const val SERVICE_CHANNEL_ID = "leukquant_daemon_channel_v11"
        private const val SERVICE_NOTIF_ID = 70001

        private const val PREFS_NAME = "leukquant_telemetry_tracker"
        private const val KEY_SEEN_IDS = "seen_event_ids"
        private const val API_URL = "https://api.leukquant.com/api/dashboard/events?limit=15&page=1"

        fun start(context: Context) {
            try {
                val intent = Intent(context, TelemetryBackgroundService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private var executor: ScheduledExecutorService? = null
    private lateinit var prefs: SharedPreferences

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        createNotificationChannels()
        startForegroundServiceNotification()
        startTelemetryPolling()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        scheduleNextAlarm()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        executor?.shutdownNow()
        scheduleNextAlarm()
        super.onDestroy()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

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

            // 1. Silent Ongoing Daemon Channel (Required for Foreground Service)
            val serviceChannel = NotificationChannel(
                SERVICE_CHANNEL_ID,
                "Autonomous Threat Sentry",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps LeukQuant autonomous decoy ingress sentry active in the background."
                setShowBadge(false)
            }
            manager.createNotificationChannel(serviceChannel)

            // 2. Critical & High Ingress Channel
            val criticalChannel = NotificationChannel(
                CRITICAL_CHANNEL_ID,
                "🚨 Critical & High Security Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Real-time audible alerts for Critical and High risk intrusion attempts that wake the screen."
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500, 200, 500)
                setSound(alarmSoundUri, alarmAudioAttributes)
                enableLights(true)
                lightColor = android.graphics.Color.RED
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setBypassDnd(true)
            }
            manager.createNotificationChannel(criticalChannel)

            // 3. Medium Ingress Channel
            val mediumChannel = NotificationChannel(
                MEDIUM_CHANNEL_ID,
                "🔶 Medium-Risk Security Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Immediate notifications for Medium risk intrusion events, honeypot probes, and decoy touches."
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 300, 150, 300)
                setSound(notifSoundUri, notifAudioAttributes)
                enableLights(true)
                lightColor = android.graphics.Color.YELLOW
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            manager.createNotificationChannel(mediumChannel)
        }
    }

    private fun startForegroundServiceNotification() {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val notification = NotificationCompat.Builder(this, SERVICE_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("LeukQuant Threat Sentry Active")
            .setContentText("Monitoring honeypots & decoy traps 24/7.")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(SERVICE_NOTIF_ID, notification)
    }

    private fun startTelemetryPolling() {
        executor = Executors.newSingleThreadScheduledExecutor()
        // Poll every 15 seconds in the background
        executor?.scheduleWithFixedDelay({
            try {
                pollBackendEvents()
            } catch (e: Exception) {
                // Sentry resilient error recovery
            }
        }, 0, 15, TimeUnit.SECONDS)
    }

    private fun pollBackendEvents() {
        var connection: HttpURLConnection? = null
        try {
            val url = URL(API_URL)
            connection = url.openConnection() as HttpURLConnection
            connection.requestMethod = "GET"
            connection.connectTimeout = 8000
            connection.readTimeout = 8000
            connection.setRequestProperty("Accept", "application/json")
            connection.setRequestProperty("User-Agent", "LeukQuant-Native-Sentry/1.0")

            val responseCode = connection.responseCode
            if (responseCode == HttpURLConnection.HTTP_OK) {
                val reader = BufferedReader(InputStreamReader(connection.inputStream))
                val sb = StringBuilder()
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    sb.append(line)
                }
                reader.close()

                processEventsPayload(sb.toString())
            }
        } catch (_: Exception) {
            // Offline or network switch
        } finally {
            connection?.disconnect()
        }
    }

    private fun processEventsPayload(jsonStr: String) {
        try {
            val seenSet = prefs.getStringSet(KEY_SEEN_IDS, mutableSetOf())?.toMutableSet() ?: mutableSetOf()
            val eventsArray = when {
                jsonStr.trim().startsWith("[") -> JSONArray(jsonStr)
                jsonStr.trim().startsWith("{") -> {
                    val root = JSONObject(jsonStr)
                    when {
                        root.has("events") -> root.getJSONArray("events")
                        root.has("attacks") -> root.getJSONArray("attacks")
                        root.has("data") -> root.getJSONArray("data")
                        else -> JSONArray()
                    }
                }
                else -> JSONArray()
            }

            val isFirstBoot = seenSet.isEmpty()
            val newlyDiscoveredIds = mutableSetOf<String>()

            for (i in 0 until eventsArray.length()) {
                val event = eventsArray.optJSONObject(i) ?: continue
                val id = event.optString("id", "")
                if (id.isEmpty()) continue

                newlyDiscoveredIds.add(id)

                // If not first initialization and we have never seen this event before -> Trigger Attack Notification!
                if (!isFirstBoot && !seenSet.contains(id)) {
                    val type = event.optString("type", event.optString("classification", "Intrusion Ingress"))
                    val ip = event.optString("source_ip", event.optString("sourceIp", "Unknown IP"))
                    val country = event.optString("country", "")
                    val port = event.optString("destination_port", event.optString("destinationPort", "22"))
                    val severity = event.optString("severity", "high").lowercase()
                    val threatLevel = event.optInt("threat_level", event.optInt("threatLevel", 3))

                    val isCritical = severity == "critical" || threatLevel >= 4
                    val isHigh = severity == "high" || threatLevel == 3
                    val isMedium = severity == "medium" || severity == "warning" || severity == "warn" || threatLevel == 2

                    if (isCritical || isHigh || isMedium) {
                        dispatchNativeAttackNotification(
                            notifId = id.hashCode() and 0x7fffffff,
                            type = type,
                            sourceIp = ip,
                            country = country,
                            port = port,
                            severity = severity,
                            isCritical = isCritical || isHigh
                        )
                    }
                }
            }

            // Update seen set (keep last 300 IDs)
            seenSet.addAll(newlyDiscoveredIds)
            if (seenSet.size > 300) {
                val trimmed = seenSet.toList().takeLast(300).toSet()
                prefs.edit().putStringSet(KEY_SEEN_IDS, trimmed).apply()
            } else {
                prefs.edit().putStringSet(KEY_SEEN_IDS, seenSet).apply()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun dispatchNativeAttackNotification(
        notifId: Int,
        type: String,
        sourceIp: String,
        country: String,
        port: String,
        severity: String,
        isCritical: Boolean
    ) {
        try {
            // 1. Wake up the locked screen immediately
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            @Suppress("DEPRECATION")
            val wakeLock = powerManager.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
                "leukquant:background_sentry_wake"
            )
            wakeLock.acquire(10000)

            // 2. Full-Screen & Lock-Screen Intent
            val notifyIntent = Intent(applicationContext, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                action = "ACTION_CRITICAL_ALERT"
                putExtra("alert_id", notifId)
            }
            val pendingIntent = PendingIntent.getActivity(
                applicationContext,
                notifId,
                notifyIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )

            val channelId = if (isCritical) CRITICAL_CHANNEL_ID else MEDIUM_CHANNEL_ID
            val title = if (isCritical) "🚨 CRITICAL ATTACK: $type" else "🔶 MEDIUM-RISK: $type"
            val countryStr = if (country.isNotEmpty()) " ($country)" else ""
            val body = "Attacker IP: $sourceIp$countryStr · Target Port: $port · Severity: ${severity.uppercase()}"

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
            manager.notify(notifId, builder.build())

            // 3. Play loud audible tone
            playNativeAlarmTone(if (isCritical) "cyberRadar" else "enterprisePing")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun playNativeAlarmTone(toneType: String) {
        try {
            val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val ringtone = RingtoneManager.getRingtone(applicationContext, ringtoneUri)
            ringtone?.play()

            val tone = when (toneType.lowercase()) {
                "cyberradar" -> ToneGenerator.TONE_CDMA_EMERGENCY_RINGBACK
                "tacticalpulse" -> ToneGenerator.TONE_PROP_BEEP2
                else -> ToneGenerator.TONE_PROP_ACK
            }
            try {
                val toneGen = ToneGenerator(AudioManager.STREAM_ALARM, 100)
                toneGen.startTone(tone, 600)
            } catch (_: Exception) {}

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator.vibrate(
                    VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 500, 200, 500), -1)
                )
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
        } catch (_: Exception) {}
    }

    private fun scheduleNextAlarm() {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, BootReceiver::class.java).apply {
                action = "ACTION_POLL_TELEMETRY"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                991,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )

            val triggerAtMillis = System.currentTimeMillis() + 60000 // 1 minute Doze wakeup alarm
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            }
        } catch (_: Exception) {}
    }
}
