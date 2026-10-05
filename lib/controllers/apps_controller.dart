import 'package:refocus/models/apps_model.dart';
import 'package:refocus/objs/app.dart';
import 'package:refocus/objs/app_monitorado.dart';
//import 'package:refocus/database/temp_database.json';
class AppsController {

  AppsModel? appsModel;

  AppsController(db) {
    appsModel = AppsModel(db);
  }

  /*METODO DE CONSULTA NO DISPOSITIVO*/
  Future<List<App>> getInstalledApps() async {
    //Pega os aplicativos instalados direto do dispositivo
    final apps = await appsModel!.getInstalledApps();
    storeInstalledApps(apps);

    return apps;
  }

  /*METODOS PARA REGISTRAR NO BANCO DE DADOS*/
  Future<void> storeInstalledApps(apps) async {
    appsModel!.storeInstalledApps(apps);
  }

  Future<void> storeMonitoredApp(packageName, tempoLimite) async {
    //Lógica para gravar app monitorado no banco de dados
    await appsModel!.storeMonitoredApp(packageName, tempoLimite);
  }

  /*METODOS PARA CONSULTAS NO BANCO DE DADOS*/
  Future<List<App>> consultInstalledApps() async {
    final apps = await appsModel!.queryAppsInstalados();

    return apps;
  }

  Future<List<AppMonitorado>> getMonitoredApps() async {
    //final query = await appsModel!.queryAppsMonitorados();
    final List<AppMonitorado> monitoredApps = await appsModel!.queryAppsMonitorados();

    return monitoredApps;
  }

  /*METODOS PARA REMOVER DO BANCO DE DADOS*/
  Future<void> removeMonitoredApp(String package) async {
    appsModel!.dropMonitoredApp(package);
  }
}