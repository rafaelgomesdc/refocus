import 'package:flutter/services.dart';

class MonitoramentoService {
  static const platform = MethodChannel('com.refocus.app/usage');

  static Future<String?> consultarAppEmUso() async {
    final app = await platform.invokeMethod<String>('getCurrentApp');

    return app;
  }
}