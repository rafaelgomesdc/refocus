import 'package:refocus/models/apps_model.dart';
//import 'package:refocus/database/temp_database.json';
class AppsController {

  AppsModel? appsModel;

  AppsController(db) {
    appsModel = AppsModel(db);
  }

  Future<List<dynamic>> getInstalledApps() async {
      final apps = appsModel!.getInstalledApps();

      return apps;
  }

  Future<List<dynamic>> getMonitoredApps() async {
    final monitoredApps = await appsModel!.queryAppsMonitorados();

    return monitoredApps;
  }
}