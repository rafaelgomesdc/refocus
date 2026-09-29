import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('refocus.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Habilita suporte a chaves estrangeiras
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabela apps
    await db.execute('''
      CREATE TABLE apps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        categoria TEXT NOT NULL,
        tempo_de_uso TEXT NOT NULL
      )
    ''');

    // 2. Tabela apps_monitorados
    await db.execute('''
      CREATE TABLE apps_monitorados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tempo_limite INTEGER NOT NULL,
        apps_id INTEGER NOT NULL,
        FOREIGN KEY (apps_id) REFERENCES apps (id) ON DELETE CASCADE
      )
    ''');

    // 3. Tabela sessao_uso
    await db.execute('''
      CREATE TABLE sessao_uso (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_inicio TEXT NOT NULL,
        data_fim TEXT NOT NULL,
        duracao INTEGER NOT NULL,
        apps_id INTEGER NOT NULL,
        FOREIGN KEY (apps_id) REFERENCES apps (id) ON DELETE CASCADE
      )
    ''');

    // 4. Tabela relatorio_diario
    await db.execute('''
      CREATE TABLE relatorio_diario (
        date TEXT PRIMARY KEY,
        tempo_total_tela INTEGER NOT NULL,
        apps_id INTEGER NOT NULL,
        sessao_uso_id INTEGER NOT NULL,
        FOREIGN KEY (apps_id) REFERENCES apps (id) ON DELETE CASCADE,
        FOREIGN KEY (sessao_uso_id) REFERENCES sessao_uso (id) ON DELETE CASCADE
      )
    ''');

    // 5. Tabela relatorio_semanal
    await db.execute('''
      CREATE TABLE relatorio_semanal (
        date TEXT PRIMARY KEY,
        tempo_total_tela INTEGER NOT NULL,
        relatorio_diario_date TEXT NOT NULL,
        FOREIGN KEY (relatorio_diario_date) REFERENCES relatorio_diario (date) ON DELETE CASCADE
      )
    ''');

    // 6. Tabela relatorio_mensal
    await db.execute('''
      CREATE TABLE relatorio_mensal (
        date TEXT PRIMARY KEY,
        tempo_total_tela INTEGER NOT NULL,
        relatorio_diario_date TEXT NOT NULL,
        FOREIGN KEY (relatorio_diario_date) REFERENCES relatorio_diario (date) ON DELETE CASCADE
      )
    ''');
  }

  // Exemplo de métodos auxiliares de CRUD podem ser adicionados aqui conforme o desenvolvimento avança
  Future<int> insertApp(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('apps', row);
  }

  Future<List<Map<String, dynamic>>> queryAllApps() async {
    final db = await instance.database;
    return await db.query('apps');
  }

  Future<int> insertAppMonitorado(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('apps_monitorados', row);
  }

  Future<List<Map<String, dynamic>>> queryAppsMonitorados(db) async {
    //final db = await instance.database;
    return await db.rawQuery('''
      SELECT am.id, am.tempo_limite, am.apps_id, a.nome, a.categoria 
      FROM apps_monitorados am
      INNER JOIN apps a ON am.apps_id = a.id
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
