import 'dart:async';

import 'package:flutter/services.dart';

class KlarnaInappFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('klarna_inapp_flutter_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
