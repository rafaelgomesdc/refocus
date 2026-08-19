package com.refocus.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.refocus.app/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
    }
}
