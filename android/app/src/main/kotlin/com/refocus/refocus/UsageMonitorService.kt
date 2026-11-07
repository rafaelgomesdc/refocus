package com.refocus.refocus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent

import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper

import android.util.Log
import com.refocus.refocus.AppBlockerService.Companion.instance

private const val TAG = "ReFocusMonitor"

class UsageMonitorService : Service() {
    /*MONITORAMENTO PRE EXISTENTE*/
    private var monitoring = false
    private var monitorThread: Thread? = null
    private var currentPackage: String? = null
    private var sessionStart: Long = 0L
    /*FIM*/

    private var appsMonitorados = mutableMapOf<String, Int>()
    var blockedPackages = mutableSetOf<String>()

    private val handler = Handler(Looper.getMainLooper())

    companion object {
        var instance: UsageMonitorService? = null
    }

    private val monitorLog = object : Runnable {
        // Log de funcionamento
        override fun run() {
            Log.d(
                TAG,
                "MONITORAMENTO ATIVO | Serviço continua executando em segundo plano"
            )

            handler.postDelayed(this, 10_000)
        }
    }

    override fun onCreate() {
        super.onCreate()

        instance = this

        Log.d(TAG, "SERVIÇO CRIADO")
        handler.post(monitorLog)
    }

    /* TESTE DEBUG */
    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        Log.d(TAG, "SERVIÇO INICIADO | startId=$startId")

        /*PRE EXISTENTE*/
        createNotification()

        getMonitoredAppsData() // Carrega os apps monitorados pela primeira vez
        updateBlockedList() // Carrega os apps bloqueados pela primeira vez
        startMonitoringthread()

        return START_STICKY
    }

    /* TESTE DEBUG */
    private fun startMonitoringthread() {
        if (monitorThread?.isAlive == true) {
            Log.w(TAG, "Monitoramento ja esta em execucao.")
            return
        }

        monitoring = true

        monitorThread = Thread {
            monitorUsage()
        }.apply {
            name = "Refocus-Monitor"
            start()
        }
    }

    fun updateBlockedList() {
        // Logica para consultar os aplicativos bloqueados
        /*
        * 1 - Consultar no banco de dados
        * 2 - Retornar uma lista de packages
        */
        val db = UsageDatabase(applicationContext)

        try {
            blockedPackages = db.getBlockedPackages()
        } finally {
            db.fechar()
        }
    }

    fun checkBlocked(packageName: String?): Boolean {
        /*
        * 1 - Verifica se o app ja esta bloqueado
        * 2 - Se sim: fecha o app e retorna true
        * 3 - Se não: retorna false
        */
        if (blockedPackages.contains(packageName)) {
            AppBlockerService.instance?.closeApp()
            return true
        }

        return false
    }

    private fun checkLimit(packageName: String?) {
        /*
        * 1 - Pegar o tempo limite no banco de dados
        * 2 - Comparar o tempo limite com o tempo de uso atual
        * 3 - Se tempo > limite = fechar e bloquear app
        */
        val _packageName = packageName ?: return
        val timeList = UsageStatsHelper.getUsageStats(applicationContext)

        for (app in timeList) {
            if (app["packageName"] == _packageName) {
                val tempoTotal = (app["totalTime"] as? Number)?.toLong() ?: 0L
                val tempoLimite = appsMonitorados[_packageName]?.toLong() ?: return

                if (tempoTotal >= tempoLimite) {
                    val db = UsageDatabase(applicationContext)

                    try {
                        db.bloquearApp(_packageName)
                    } finally {
                        db.fechar()
                    }

                    AppBlockerService.instance?.closeApp()
                    AppBlockerService.instance?.updateBlockedList()
                }
            }
        }
    }

    fun reconcileBlockedApps() {

        val db = UsageDatabase(applicationContext)

        try {
            val usageStats = UsageStatsHelper.getUsageStats(applicationContext)

            for ((packageName, tempoLimite) in appsMonitorados) {

                val appUsage = usageStats.firstOrNull {
                    it["packageName"] == packageName
                }

                val tempoUso = (appUsage?.get("totalTime") as? Number)
                    ?.toLong() ?: 0L

                val limite = tempoLimite.toLong()

                if (tempoUso >= limite) {

                    db.bloquearApp(packageName)

                    Log.d(TAG, "$packageName continua bloqueado")

                } else {

                    db.desbloquearApp(packageName)

                    Log.d(TAG, "$packageName foi desbloqueado")
                }
            }

        } finally {
            db.fechar()
        }

        // Atualiza as listas em memória
        updateBlockedList()
        AppBlockerService.instance?.updateBlockedList()
    }

    fun getMonitoredAppsData() {
        val db = UsageDatabase(applicationContext)
        var _appsMonitorados = mutableMapOf<String, Int>()

        try {
            _appsMonitorados = db.getMonitoredApps()
        } finally {
            db.fechar()
        }

        appsMonitorados = _appsMonitorados
    }

    /*PRE EXISTENTE*/
    private fun monitorUsage() {

        Log.d(TAG, "Monitoramento Iniciado")

        while (monitoring) {
            // Monitoramento continuo
            try {
                val packageName = UsageStatsHelper.getCurrentApp(this)

                if (packageName == null) {
                    Log.w(TAG, "Nenhum aplicativo identificado. Mantendo estado anterior")

                    Thread.sleep(1000)

                    if (checkBlocked(currentPackage) == true) {
                        // Verifica o bloqueio, se já estiver bloqueado pula o restante da logica de monitoramento
                        continue
                    }

                    checkLimit(currentPackage) // Verifica limite e bloqueia/fecha o app se aplicavel

                    continue
                }

                Log.d(TAG, "Aplicativo atual: $packageName")

                if (packageName != currentPackage) {
                    // Encerrar sessao anterior
                    if (currentPackage != null && sessionStart > 0) {
                        if (currentPackage == "com.refocus.refocus")
                            getMonitoredAppsData() // Recarrega os apps monitorados apos possiveis alteracoes
                            updateBlockedList() // Recarrega os apps bloqueados apos possiveis alteracoes
                        closeSession()
                    }

                    // Iniciar nova sessao (com novo aplicativo)
                    currentPackage = packageName
                    sessionStart = System.currentTimeMillis()

                    Log.d(TAG, "Sessao iniciada: $packageName")
                }

                Thread.sleep(1000)

                if (checkBlocked(currentPackage) == true) {
                    // Verifica o bloqueio, se já estiver bloqueado pula o restante da logica de monitoramento
                    continue
                }

                checkLimit(currentPackage) // Verifica limite e bloqueia/fecha o app se aplicavel
            } catch (e: InterruptedException) {
                Log.d(TAG, "Thread de monitoramento interrompida")
                break

            } catch (e: Exception) {
                Log.e(TAG, "Erro durante monitoramento", e)

                try {
                    Thread.sleep(1000)
                } catch (interrupted: InterruptedException) {
                    break
                }
            }
        }

        Log.d(TAG, "Monitoramento finalizado")
    }

    private fun closeSession() {
        // Encerra a sessão
        val end = System.currentTimeMillis()
        val duration = (end - sessionStart) / 1000

        Log.d(TAG, "Sessao encerrada: $currentPackage")
        Log.d(TAG, "Duracao: $duration segundos")

        // Lógica para registrar no banco de dados
        val db = UsageDatabase(applicationContext)

        try {
            val agora = System.currentTimeMillis()
            val inicio = agora - 60_000L

            val id = db.registrarSessao(
                packageName = (currentPackage ?: ""),
                inicio = inicio,
                fim = agora
            )

            if (id > 0) {
                Log.d(
                    "ReFocus",
                    "Sessao registrada: $id"
                )
            }
        } finally {
            db.fechar()
        }

        sessionStart = 0L
    }
    /*FIM*/

    override fun onDestroy() {
        instance = null

        handler.removeCallbacks(monitorLog)
        Log.w(TAG, "SERVIÇO DESTRUÍDO")

        /*PRE EXISTENTE*/
        monitoring = false

        if (currentPackage != null && sessionStart > 0) {
            closeSession()
        }
        /*FIM*/
        super.onDestroy()
    }

    private fun createNotification() {
        val channelId = "refocus_monitor_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Monitoramento do ReFocus",
                NotificationManager.IMPORTANCE_LOW
            )

            val manager = getSystemService(
                NotificationManager::class.java
            )

            manager.createNotificationChannel(channel)
        }

        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
                .setContentTitle("ReFocus")
                .setContentText("Monitoramento de uso ativo")
                .setSmallIcon(android.R.drawable.ic_menu_info_details)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("ReFocus")
                .setContentText("Monitoramento de uso ativo")
                .setSmallIcon(android.R.drawable.ic_menu_info_details)
                .build()
        }

        startForeground(1, notification)

        Log.d(TAG, "Serviço promovido a primeiro plano")
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}