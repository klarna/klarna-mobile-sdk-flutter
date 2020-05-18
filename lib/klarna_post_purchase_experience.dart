import 'dart:async';

import 'package:flutter/services.dart';

class KlarnaPostPurchaseExperience {
  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_experience');

  static Future<void> initialize(String locale, String purchaseCountry, String design) async {
    return await _channel.invokeMethod('initialize', <String, dynamic>{
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design
    });
  }

  static Future<void> renderOperation(
      String locale, String operationToken) async {
    return await _channel.invokeMethod('renderOperation',
        <String, dynamic>{'locale': locale, 'operationToken': operationToken});
  }

  static Future<void> authorizationRequest(String locale, String clientId,
      String scope, String redirectUri, String state, String loginHint) async {
    return await _channel
        .invokeMethod('authorizationRequest', <String, dynamic>{
      'locale': locale,
      'clientId': clientId,
      'scope': scope,
      'redirectUri': redirectUri,
      'state': state,
      'loginHint': loginHint,
    });
  }
}
