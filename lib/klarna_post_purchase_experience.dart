import 'dart:async';

import 'package:flutter/services.dart';

class KlarnaPostPurchaseExperience {

  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_experience');

  static Future<void> initialize(String locale, String purchaseCountry,
      {String design}) async {
    return await _channel.invokeMethod('initialize', <String, dynamic>{
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design
    });
  }

  static Future<void> destroy() async {
    return await _channel.invokeMethod('destroy');
  }

  static Future<String> renderOperation(String operationToken,
      {String locale}) async {
    return await _channel.invokeMethod('renderOperation',
        <String, dynamic>{'locale': locale, 'operationToken': operationToken});
  }

  static Future<void> authorizationRequest(
      String clientId, String scope, String redirectUri,
      {String locale,
      String state,
      String loginHint,
      String responseType}) async {
    return await _channel
        .invokeMethod('authorizationRequest', <String, dynamic>{
      'locale': locale,
      'clientId': clientId,
      'scope': scope,
      'redirectUri': redirectUri,
      'state': state,
      'loginHint': loginHint,
      'responseType': responseType
    });
  }
}
