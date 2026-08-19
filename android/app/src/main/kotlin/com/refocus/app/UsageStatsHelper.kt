package com.refocus.app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import java.util.Calendar

object UsageStatsHelper {

    // Verifica se a permissão especial de Acesso a Estatísticas de Uso está concedida
    fun hasUsageStatsPermission(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    // Direciona o usuário para a tela de configurações para ativar a permissão
    fun openUsageSettings(context: Context) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    // Coleta estatísticas de tempo de tela do dia atual
    fun getUsageStats(context: Context): List<Map<String, Any>> {
        val list = mutableListOf<Map<String, Any>>()
        if (!hasUsageStatsPermission(context)) {
            return list
        }

        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        
        // Define o início do dia de hoje (00:00:00)
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        // Consulta o histórico diário
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        if (stats != null) {
            for (usageStat in stats) {
                val totalTime = usageStat.totalTimeInForeground
                // Filtra apenas apps com tempo de uso ativo maior que zero
                if (totalTime > 0) {
                    val item = mapOf(
                        "packageName" to usageStat.packageName,
                        "totalTime" to totalTime // Retorna em milissegundos
                    )
                    list.add(item)
                }
            }
        }
        return list
    }
}
