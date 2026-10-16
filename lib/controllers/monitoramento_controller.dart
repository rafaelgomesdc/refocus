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
}