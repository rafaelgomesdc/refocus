package com.refocus.refocus

import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.pm.ApplicationInfo

class MainActivity: FlutterActivity() {
    private val USAGE_CHANNEL = "com.refocus.app/usage"
    private val APP_INFO_CHANNEL = "com.refocus/app_info" //channel para acessar os packages

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsageStats" -> {
                    val stats = UsageStatsHelper.getUsageStats(context)
                    result.success(stats)
                }
                "checkUsagePermission" -> {
                    result.success(UsageStatsHelper.hasUsageStatsPermission(context))
                }
                "openUsageSettings" -> {
                    UsageStatsHelper.openUsageSettings(context)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

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
