import "package:refocus/services/app_info_service.dart";
import "package:refocus/objs/app.dart";
import "package:refocus/objs/app_monitorado.dart";
import 'package:sqflite/sqflite.dart';

class AppsModel {
  final db;

  AppsModel(this.db);

  /*METODO DE CONSULTA NO DISPOSITIVO*/
  Future<List<App>> getInstalledApps() async {
    final queryApps = await AppInfoService.getInstalledAppsFromDevice();
    List<App> appsList = [];

    for (var app in queryApps) {
      App _app = App(app['name'], app['packageName']);
      appsList.add(_app);
    }

    return appsList;
  }

  /*METODOS PARA REGISTRAR NO BANCO DE DADOS*/
  Future<void> storeInstalledApps(apps) async {
    //Lógica para gravar apps instalados no banco de dados

    for (var app in apps!) {
      await db.insert('apps', {
        'package': app.packageName,
        'nome': app.name,
        'categoria': '',
        'tempo_de_uso': '',
      },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

    }
  }

  Future<void> storeMonitoredApp(packageName, tempoLimite) async {
    //Lógica para gravar app monitorado no banco de dados
    await db.insert('apps_monitorados', {
      'apps_package': packageName,
      'tempo_limite': tempoLimite
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /*METODOS PARA CONSULTAS NO BANCO DE DADOS*/
  Future<List<AppMonitorado>> queryAppsMonitorados() async {
    final queryAppsMonitorados = await db.rawQuery('''
      SELECT
        am.tempo_limite,
        am.apps_package,
        a.nome
      FROM apps_monitorados am
      INNER JOIN apps a ON am.apps_package = a.package
      ORDER BY a.nome
    ''');
    List<AppMonitorado> appsList = [];

    for (var app in queryAppsMonitorados) {
      AppMonitorado _app = AppMonitorado(
        app['nome'] as String,
        app['apps_package'] as String,
        app['tempo_limite'],
      );

      appsList.add(_app);
    }

    return appsList;
  }

  Future<List<App>> queryAppsInstalados() async {
    final queryApps = await db.rawQuery('''
      SELECT
        a.package,
        a.nome
      FROM apps a
      ORDER BY a.nome
    ''');
    List<App> appsList = [];

    for (var app in queryApps) {
      App _app = App(app['nome'] as String, app['package'] as String);
      appsList.add(_app);
    }

    return appsList;
  }

  /*METODOS PARA REMOVER DO BANCO DE DADOS*/
  Future<void> dropMonitoredApp(String package) async {
    // Remove o app monitorado 'package'
    await db.delete(
      'apps_monitorados',
      where: 'apps_package = ?',
      whereArgs: [package],
    );
  }
}