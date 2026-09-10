import 'package:flutter/services.dart';

class AppInfoService {
  static const MethodChannel _channel = MethodChannel('com.refocus/app_info');

  static Future<List<dynamic>> getInstalledAppsFromDevice() async {
    //Pega os aplicativos instalados no dispositivo acessando packages
    final result = await _channel.invokeMethod('getInstalledApps');

    return result;
  }
}