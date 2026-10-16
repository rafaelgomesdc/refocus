package com.refocus.refocus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder

import android.util.Log

private const val TAG = "ReFocusMonitor"

class UsageMonitorService : Service() {
    private var monitoring = false
    private var currentPackage: String? = null
    private var sessionStart: Long = 0L

    private lateinit var monitorThread: Thread

    override fun onCreate() {
        super.onCreate()

        createNotificationChannel()

        startForeground(1001, createNotification())

        monitoring = true

        monitorThread = Thread {
            //monitorUsage()
        }

        monitorThread.start()
    }

    private fun monitorUsage() {

        Log.d(TAG, "Monitoramento Iniciado")

        while (monitoring) {
            try {
                val packageName = UsageStatsHelper.getCurrentApp(this)

                Log.d(TAG, "Aplicativo atual: $packageName")

                if (packageName != currentPackage) {
                    //Encerrar sessao anterior
                    if (currentPackage != null && sessionStart > 0) {
                        closeSession()
                    }

                    //Iniciar nova sessao (com novo aplicativo)
                    currentPackage = packageName
                    sessionStart = System.currentTimeMillis()

                    Log.d(TAG, "Sessao iniciada: $packageName")
                }

                Thread.sleep(1000)
            } catch (e: Exception) {
                //e.printStackTrace()

                Log.e(TAG, "Erro durante monitoramento", e)
            }
        }

        Log.d(TAG, "Monitoramento finalizado")
    }

    private fun closeSession() {
        val end = System.currentTimeMillis()
        val duration = (end - sessionStart) / 1000

        Log.d(TAG, "Sessao encerrada: $currentPackage")
        Log.d(TAG, "Duracao: $duration segundos")

        //println("APP: $currentPackage")
        //println("DURAÇÃO: $duration segundos")

        //Registrar no banco de dados

        sessionStart = 0L
    }

    override fun onDestroy() {
        monitoring = false

        if (currentPackage != null && sessionStart > 0) {
            closeSession()
        }

        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel("refocus_monitor", "Monitoramento do ReFocus", NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(NotificationManager::class.java)

            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return Notification.Builder(this, "refocus_monitor")
            .setContentTitle("ReFocus")
            .setContentText("Monitoramento de uso ativo")
            .setSmallIcon(android.R.drawable.ic_menu_info_details)
            .setOngoing(true)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}