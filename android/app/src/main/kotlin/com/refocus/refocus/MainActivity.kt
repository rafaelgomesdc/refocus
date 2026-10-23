package com.refocus.refocus

import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.pm.ApplicationInfo

import android.util.Log

//UsageStats
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val USAGE_CHANNEL = "com.refocus.app/usage"
    private val APP_INFO_CHANNEL = "com.refocus/app_info" //channel para acessar os packages

    /*
    private fun getCurrentApp(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 1000 * 60 //Ultimos 60 segundos

        val events = usageStatsManager.queryEvents(startTime, endTime)

        val event = UsageEvents.Event()

        var currentPackage: String? = null

        while (events.hasNextEvent()) {
            events.getNextEvent(event)

            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                currentPackage = event.packageName
            }
        }

        return currentPackage
    }
    */

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        /*DADOS DE USO*/
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentApp" -> {
                    val app = UsageStatsHelper.getCurrentApp(this)
                    result.success(app)
                }
                "getUsageStats" -> {
                    val stats = UsageStatsHelper.getUsageStats(this)
                    result.success(stats)
                }
                "checkUsagePermission" -> {
                    result.success(UsageStatsHelper.hasUsageStatsPermission(this))
                }
                "openUsageSettings" -> {
                    UsageStatsHelper.openUsageSettings(this)
                    result.success(true)
                }
                "startMonitoring" -> {

                    android.util.Log.d(
                        "ReFocusMonitor",
                        "========== START MONITORING CHAMADO =========="
                    )

                    val intent = Intent(this, UsageMonitorService::class.java)

                    startForegroundService(intent)

                    result.success(true)
                }
                "stopMonitoring" -> {
                    android.util.Log.d(
                        "ReFocusMonitor",
                        "========== STOP MONITORING CHAMADO =========="
                    )

                    val intent = Intent(this, UsageMonitorService::class.java)

                    stopService(intent)

                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        /*DADOS DOS APLICATIVOS*/
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_INFO_CHANNEL
        ).setMethodCallHandler { call, result -> when (call.method) {
            "getInstalledApps" -> {
                val packageManager = packageManager

                val apps = packageManager.getInstalledApplications(0).filter {
                    it.flags and ApplicationInfo.FLAG_SYSTEM == 0
                }
                    .map { app -> mapOf(
                        "name" to packageManager
                            .getApplicationLabel(app)
                            .toString(),

                        "packageName" to app.packageName
                    )
                    }
                result.success(apps)
            }
            else -> {
                result.notImplemented()
            }
        } }
    }
}
