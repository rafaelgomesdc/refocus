import 'package:flutter/services.dart';
import 'package:refocus/objs/app_monitorado.dart';
import 'package:refocus/services/monitoramento_service.dart';

class MonitoramentoController {

  Future<void> consultarAppEmUso() async {
    final app = await MonitoramentoService.consultarAppEmUso();

    print(app);
  }

  bool verificarAppMonitorado() {
    return true;
  }

  void RegistrarUso() {}

  Future<Map<dynamic, dynamic>> consultarUsoHoje(List<AppMonitorado> _appsMonitorados) async {
    const MethodChannel _channel = MethodChannel('com.refocus.app/usage');
    var appsUsageData = await _channel.invokeMethod('getUsageStats');
    Map<dynamic, dynamic> _appsTimeList = {};

    for (var app in appsUsageData) {
      for (var appMonitorado in _appsMonitorados)
        if (app['packageName'] == appMonitorado.packageName) {
          /*var appTimeData = {
            appMonitorado.packageName: app['totalTime'],
          };*/
          if (app['totalTime'] == null) {
            app['totalTime'] = 0;
          }
          _appsTimeList[app['packageName']] = app['totalTime'];
        }
    }

    return _appsTimeList;
  }
}