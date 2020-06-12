import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

class KlarnaPostPurchaseExperience {
  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_experience');

  static final idRandom = Random.secure();

  var id = idRandom.nextInt(999999999);

  KlarnaPostPurchaseExperience._();

  static Future<KlarnaPostPurchaseExperience> initialize(String locale, String purchaseCountry,
      {String design}) async {
    var instance = KlarnaPostPurchaseExperience._();
    await _channel.invokeMethod('initialize', <String, dynamic>{
      'id': instance.id,
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design
    });
    return instance;
  }

  Future<void> destroy() async {
    return await _channel.invokeMethod('destroy', <String, dynamic>{'id': id});
  }

  Future<String> renderOperation(String operationToken, {String locale}) async {
    return await _channel.invokeMethod('renderOperation', <String, dynamic>{
      'id': id,
      'locale': locale,
      'operationToken': operationToken
    });
  }

  Future<void> authorizationRequest(
      String clientId, String scope, String redirectUri,
      {String locale,
      String state,
      String loginHint,
      String responseType}) async {
    return await _channel
        .invokeMethod('authorizationRequest', <String, dynamic>{
      'id': id,
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
