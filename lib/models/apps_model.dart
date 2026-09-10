import "package:refocus/services/app_info_service.dart";

class AppsModel {

  AppsModel();

  Future<List<dynamic>> getInstalledApps() async {
    final apps = AppInfoService.getInstalledAppsFromDevice();

    return apps;
  }
}