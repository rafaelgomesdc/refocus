package com.refocus.app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.util.Log

class AppBlockerService : AccessibilityService() {

    companion object {
        // Lista estática temporária para fins de teste.
        // Contém os IDs de pacotes do Instagram e TikTok (Musically).
        val blockedPackages = mutableSetOf(
            "com.instagram.android",
            "com.zhiliaoapp.musically" // TikTok
        )
    }

    // Método chamado pelo sistema sempre que ocorre um evento relevante (ex: abertura de app)
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            
            if (packageName != null) {
                Log.d("AppBlockerService", "Usuário abriu o app: $packageName")
                
                // Se o aplicativo aberto estiver na lista de bloqueados (tempo limite atingido)
                if (blockedPackages.contains(packageName)) {
                    Log.w("AppBlockerService", "App bloqueado detectado! Redirecionando para a Home.")
                    
                    // Executa a ação global de pressionar o botão Home do Android, saindo do app
                    performGlobalAction(GLOBAL_ACTION_HOME)
                }
            }
        }
    }

    override fun onInterrupt() {
        Log.e("AppBlockerService", "Serviço de acessibilidade foi interrompido.")
    }
}
