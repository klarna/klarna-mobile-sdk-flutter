import 'dart:async';

import 'package:flutter/services.dart';

class KlarnaHybridSDK {
  static const MethodChannel _channel =
      const MethodChannel('klarna_hybrid_sdk');

  static Future<void> initialize(String returnUrl) async {
    return await _channel
        .invokeMethod('initialize', <String, dynamic>{'returnUrl': returnUrl});
  }
}
