package com.refocus.app

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
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
    }
}