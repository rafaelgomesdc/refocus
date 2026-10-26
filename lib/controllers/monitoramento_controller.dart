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

  Future<List> consultarUsoHoje(List<AppMonitorado> _appsMonitorados) async {
    const MethodChannel _channel = MethodChannel('com.refocus/usage');
    var appsUsageData = await _channel.invokeMethod('getUsageStats');
    var _appsTimeList = [];

    for (var app in appsUsageData) {
      for (var appMonitorado in _appsMonitorados)
        if (app.packageName == appMonitorado.packageName) {
          _appsTimeList.add(app.totalTime);
        }
    }

    return _appsTimeList;
  }
}