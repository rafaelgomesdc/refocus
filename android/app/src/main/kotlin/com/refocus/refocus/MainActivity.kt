package com.refocus.refocus

import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.pm.ApplicationInfo

import android.util.Log

//UsageStats
import android.content.Intent

class  MainActivity: FlutterActivity() {
    private val USAGE_CHANNEL = "com.refocus.app/usage"
    private val APP_INFO_CHANNEL = "com.refocus/app_info" //channel para acessar os packages

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        requestNotificationPermission()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        /*DADOS DE USO*/
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentApp" -> { // Retorna o atual aplicativo exibido na tela
                    val app = UsageStatsHelper.getCurrentApp(this)
                    result.success(app)
                }
                "getUsageStats" -> { // Pega os dados de uso
                    val stats = UsageStatsHelper.getUsageStats(this)
                    result.success(stats)
                }
                "checkUsagePermission" -> { // Verifica a permissao de acesso aos dados de uso
                    result.success(UsageStatsHelper.hasUsageStatsPermission(this))
                }
                "openUsageSettings" -> { // Abre as configuracoes
                    UsageStatsHelper.openUsageSettings(this)
                    result.success(true)
                }
                "updateBlockedList" -> { // Atualiza a lista de aplicativo bloqueados no 'AppBlockerService'
                    AppBlockerService.instance?.updateBlockedList()
                    UsageMonitorService.instance?.getMonitoredAppsData()
                    UsageMonitorService.instance?.reconcileBlockedApps()
                    result.success(true)
                }
                "startMonitoring" -> { // Inicia o monitoramento em segundo plano

                    android.util.Log.d(
                        "ReFocusMonitor",
                        "========== START MONITORING CHAMADO =========="
                    )

                    val intent = Intent(this, UsageMonitorService::class.java)

                    startForegroundService(intent)

                    result.success(true)
                }
                "stopMonitoring" -> { // Encerra o monitoramento em segundo plano
                    android.util.Log.d(
                        "ReFocusMonitor",
                        "========== STOP MONITORING CHAMADO =========="
                    )

                    val intent = Intent(this, UsageMonitorService::class.java)

                    stopService(intent)

                    result.success(true)
                }
                "testNotification" -> {
                    val service = UsageMonitorService.instance

                    if (service != null) {
                        service.testNotification()
                        result.success(true)
                    } else {
                        result.error(
                            "SERVICE_NOT_RUNNING",
                            "O serviço de monitoramento não está ativo.",
                            null
                        )
                    }
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
            "getInstalledApps" -> { // Retorna os aplicativos instalados no dispositivo
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

    private fun requestNotificationPermission() {
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            if (checkSelfPermission(
                    android.Manifest.permission.POST_NOTIFICATIONS
                ) != android.content.pm.PackageManager.PERMISSION_GRANTED
            ) {
                requestPermissions(
                    arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                    1001
                )
            }
        }
    }
}
