package com.refocus.refocus

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class UsageDatabase(context: Context) {
    private val db: SQLiteDatabase

    init {
        val arquivo = context.getDatabasePath("refocus.db")

        check(arquivo.exists()) {
            "Banco não encontrado. Inicializar via Flutter."
        }

        db = SQLiteDatabase.openDatabase(
            arquivo.absolutePath,
            null,
            SQLiteDatabase.OPEN_READWRITE
        )

        db.setForeignKeyConstraintsEnabled(true)
    }

    fun registrarSessao(
        packageName: String,
        inicio: Long,
        fim: Long
    ): Long {
        require(fim >= inicio) {
            "O fim nao pode ser anterior ao inicio."
        }

        val duracao = (fim - inicio) / 1000

        val formato = SimpleDateFormat(
            "yyyy-MM-dd HH:mm:ss",
            Locale.US
        )

        val dataInicio = formato.format(Date(inicio))
        val dataFim = formato.format(Date(fim))

        db.beginTransaction()

        try {
            Log.d("ReFocus", "Buscando aplicativo: $packageName")

            // Verifica se o app esta cadastrado e monitorado
            val cursor = db.rawQuery(
                """
                    SELECT a.id
                    FROM apps a
                    INNER JOIN apps_monitorados am
                        ON am.apps_package = a.package
                    WHERE a.package = ?
                """.trimIndent(),
                arrayOf(packageName)
            )

            val appId: Long

            cursor.use {
                if (!it.moveToFirst()) {
                    Log.w(
                        "ReFocus",
                        "Aplicativo não encontrado ou não monitorado: $packageName"
                    )

                    return -1L
                }

                appId = it.getLong(0)
            }

            val valores = ContentValues().apply {
                put("data_inicio", dataInicio)
                put("data_fim", dataFim)
                put("duracao", duracao)
                put("apps_id", appId)
                put("apps_package", packageName)
            }

            val id = db.insertOrThrow(
                "sessao_uso",
                null,
                valores
            )

            db.setTransactionSuccessful()

            return id
        } finally {
            db.endTransaction()
        }
    }

    fun fechar() {
        if (db.isOpen) {
            db.close()
        }
    }
}