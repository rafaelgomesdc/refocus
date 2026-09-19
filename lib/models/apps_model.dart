import "package:refocus/services/app_info_service.dart";

class AppsModel {
  final db;

  AppsModel(this.db);

  Future<List<dynamic>> getInstalledApps() async {
    final apps = AppInfoService.getInstalledAppsFromDevice();

    return apps;
  }
}