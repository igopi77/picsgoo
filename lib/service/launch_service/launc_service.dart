import 'package:flutter/services.dart';

class LauncherService {
  static const MethodChannel _channel = MethodChannel('launcher_service');

  static Future<void> setAsDefaultLauncher() async {
    try {
      await _channel.invokeMethod('setAsDefaultLauncher');
    } on PlatformException catch (e) {
      print("Failed to set as default launcher: '${e.message}'.");
    }
  }
}
