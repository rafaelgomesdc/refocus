import "package:refocus/services/app_info_service.dart";

class AppsModel {
  final db;

  AppsModel(this.db);

  Future<List<dynamic>> getInstalledApps() async {
    final apps = AppInfoService.getInstalledAppsFromDevice();

    return apps;
  }

  Future<List<Map<String, dynamic>>> queryAppsMonitorados() async {
    return await db.rawQuery('''
      SELECT am.id, am.tempo_limite, am.apps_id, a.nome, a.categoria 
      FROM apps_monitorados am
      INNER JOIN apps a ON am.apps_id = a.id
    ''');
  }
}