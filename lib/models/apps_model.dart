import "package:refocus/services/app_info_service.dart";
import "package:refocus/objs/app.dart";

class AppsModel {
  final db;

  AppsModel(this.db);

  Future<List<App>> getInstalledApps() async {
    final queryApps = await AppInfoService.getInstalledAppsFromDevice();
    List<App> appsList = [];

    for (var app in queryApps) {
      App _app = App(app['name'], app['packageName']);
      appsList.add(_app);
    }

    return appsList;
  }

  Future<void> storeInstalledApps(apps) async {
    //Lógica para gravar apps instalados no banco de dados

    for (var app in apps!) {
      await db.insert('apps', {
        'package': app.packageName,
        'nome': app.name,
        'categoria': '',
        'tempo_de_uso': '',
      });
    }
  }

  Future<void> storeMonitoredApp(app) async {
    //Lógica para gravar app monitorado no banco de dados
  }

  Future<List<Map<String, dynamic>>> queryAppsMonitorados() async {
    return await db.rawQuery('''
      SELECT
        am.tempo_limite,
        am.status,
        am.bloqueado,
        am.apps_id,
        am.apps_package,
        a.nome,
        a.categoria
      FROM apps_monitorados am
      INNER JOIN apps a ON am.apps_id = a.id
    ''');
  }

  Future<List<App>> queryAppsInstalados() async {
    //Consulta os apps instalados pelo banco de dados
    final queryApps = await db.rawQuery('''
      SELECT
        a.package,
        a.nome
      FROM apps a
    ''');
    List<App> appsList = [];

    for (var app in queryApps) {
      App _app = App(app['nome'] as String, app['package'] as String);
      appsList.add(_app);
    }

    return appsList;
  }
}