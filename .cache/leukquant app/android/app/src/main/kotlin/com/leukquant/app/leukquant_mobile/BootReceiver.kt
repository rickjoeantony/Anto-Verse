package com.leukquant.app.leukquant_mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Automatically starts the LeukQuant 24/7 Threat Sentry Service when the phone turns on in the morning.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON" ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == "ACTION_POLL_TELEMETRY") {
            TelemetryBackgroundService.start(context)
        }
    }
}
