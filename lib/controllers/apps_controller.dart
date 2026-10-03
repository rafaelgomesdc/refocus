import 'package:refocus/models/apps_model.dart';
import 'package:refocus/objs/app.dart';
//import 'package:refocus/database/temp_database.json';
class AppsController {

  AppsModel? appsModel;

  AppsController(db) {
    appsModel = AppsModel(db);
  }

  Future<void> storeInstalledApps(apps) async {
    //Lógica para gravar apps instalados no banco de dados
    appsModel!.storeInstalledApps(apps);
  }

  Future<List<App>> getInstalledApps() async {
    //Pega os aplicativos instalados direto do dispositivo
    final apps = await appsModel!.getInstalledApps();
    storeInstalledApps(apps);

    return apps;
  }

  Future<List<dynamic>> getMonitoredApps() async {
    final monitoredApps = await appsModel!.queryAppsMonitorados();

    return monitoredApps;
  }

  void storeMonitoredApp(app) {
    //Lógica para gravar app monitorado no banco de dados
  }

  Future<List<App>> consultInstalledApps() async {
    //Consulta os apps instalados no banco de dados
    final apps = await appsModel!.queryAppsInstalados();


    return apps!;
  }
}