import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

class KlarnaPostPurchaseExperience {
  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_experience');

  static final _idRandom = Random.secure();

  var _id = _idRandom.nextInt(999999999);

  KlarnaPostPurchaseExperience();

  static Future<KlarnaPostPurchaseExperience> init(
      String locale, String purchaseCountry,
      {String design}) async {
    var instance = KlarnaPostPurchaseExperience();
    await instance.initialize(locale, purchaseCountry, design: design);
    return instance;
  }

  Future<void> initialize(String locale, String purchaseCountry,
      {String design}) async {
    return await _channel.invokeMethod('initialize', <String, dynamic>{
      'id': _id,
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design
    });
  }

  Future<void> destroy() async {
    return await _channel.invokeMethod('destroy', <String, dynamic>{'id': _id});
  }

  Future<String> renderOperation(String operationToken, {String locale}) async {
    return await _channel.invokeMethod('renderOperation', <String, dynamic>{
      'id': _id,
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
      'id': _id,
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
