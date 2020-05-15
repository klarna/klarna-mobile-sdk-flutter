import 'dart:async';

import 'package:flutter/services.dart';

class KlarnaWebView {
  static const MethodChannel _channel = const MethodChannel('klarna_web_view');

  static Future<void> initialize() async {
    return await _channel.invokeMethod('initialize');
  }

  static Future<void> destroy() async {
    return await _channel.invokeMethod('destroy');
  }

  static Future<void> show() async {
    return await _channel.invokeMethod('show');
  }

  static Future<void> hide() async {
    return await _channel.invokeMethod('hide');
  }

  static Future<String> loadURL(String url) async {
    final String result =
        await _channel.invokeMethod('loadURL', <String, dynamic>{'url': url});
    return result;
  }

  static Future<String> loadJS(String js) async {
    final String result =
        await _channel.invokeMethod('loadURL', <String, dynamic>{'js': js});
    return result;
  }

  static Future<void> addToHybridSdk() async {
    await _channel.invokeMethod('addToHybridSdk');
  }
}
