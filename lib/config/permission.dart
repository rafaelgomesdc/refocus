import 'package:flutter/services.dart';

const usagePlatform = MethodChannel('com.refocus.app/usage');

Future<bool> checkPermissions() async {
  var usagePermission = await _checkUsagePermission();

  if (!usagePermission) {
    _openUsageSettings();
  }
  else { return true; }

  return false;
}

Future<bool> _checkUsagePermission() async {
  // Verifica a permissão para acesso aos dados de uso
  const platform = usagePlatform;
  var permission = await platform.invokeMethod('checkUsagePermission');

  if (permission) {
    return true;
  }
  else { return false; }
}

void _openUsageSettings() {
  const platform = usagePlatform;
  platform.invokeMethod('openUsageSettings');
}