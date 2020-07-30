import 'dart:async';

import 'package:flutter/services.dart';

class KlarnaHybridSDK {
  static const MethodChannel _channel =
      const MethodChannel('klarna_hybrid_sdk');
  static const EventChannel _eventChannel =
      const EventChannel('klarna_hybrid_sdk_events');

  static Future<Null> initialize(String returnUrl) async {
    return await _channel
        .invokeMethod('initialize', <String, dynamic>{'returnUrl': returnUrl});
  }

  static Future<Null> registerEventListener(Function(String) listener) async {
    await _channel.invokeMethod('registerEventListener');
    _eventChannel
        .receiveBroadcastStream()
        .map<String>((event) => event)
        .listen(listener);
    return null;
  }
}
