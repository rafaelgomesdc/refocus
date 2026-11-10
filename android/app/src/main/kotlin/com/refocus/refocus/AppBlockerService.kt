package com.refocus.refocus

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class AppBlockerService : AccessibilityService() {
    val TAG = "AppBlockerService"
    private lateinit var database: UsageDatabase
    var blockedPackages = mutableSetOf<String>()

    companion object {
        var instance: AppBlockerService? = null
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()

        instance = this

        updateBlockedList()

        Log.i(TAG, "SERVICO INICIALIZADO COM SUCESSO!")
        Log.d(TAG, "Apps bloqueados: $blockedPackages")
    }

    fun closeApp() {
        performGlobalAction(GLOBAL_ACTION_HOME)

        showNotification(
            "Limite de uso atingido!",
            "O aplicativo foi bloqueado pelo ReFocus."
        )
    }

    private fun showNotification(
        title: String,
        message: String
    ) {
        val channelId = "refocus_alerts"

        val manager = getSystemService(
            NotificationManager::class.java
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Alertas do ReFocus",
                NotificationManager.IMPORTANCE_HIGH
            )

            channel.description = "Alertas sobre o uso de aplicativos"

            manager.createNotificationChannel(channel)
        }

        val notification = Notification.Builder(
            this,
            channelId
        )
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_menu_info_details)
            .setAutoCancel(true)
            .build()

        manager.notify(
            1001,
            notification
        )
    }

    fun updateBlockedList() {
        // Logica para consultar os aplicativos bloqueados
        /*
        * 1 - Consultar no banco de dados
        * 2 - Retornar uma lista de packages
        */
        database = UsageDatabase(applicationContext)

        try {
            blockedPackages = database.getBlockedPackages()
        } finally {
            database.fechar()
        }
    }

    // Metodo chamado pelo sistema sempre que ocorre um evento relevante (ex: abertura de app)
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()

            if (packageName != null) {
                Log.d(TAG, "Usuário abriu o app: $packageName")

                // Se o aplicativo aberto estiver na lista de bloqueados (tempo limite atingido)
                if (blockedPackages.contains(packageName)) {
                    Log.w(TAG, "App bloqueado detectado! Redirecionando para a Home.")

                    // Executa a ação global de pressionar o botão Home do Android, saindo do app
                    closeApp()
                }
            }
        }
    }

    override fun onInterrupt() {
        Log.e("AppBlockerService", "Serviço de acessibilidade foi interrompido.")
    }

    override fun onDestroy() {
        instance = null

        if (::database.isInitialized) {
            database.fechar()
        }

        super.onDestroy()
    }
}
