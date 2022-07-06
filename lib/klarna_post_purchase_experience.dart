import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_environment.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_result.dart';

class KlarnaPostPurchaseExperience {
  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_experience');

  static final _idRandom = Random.secure();

  var _id = _idRandom.nextInt(999999999);

  KlarnaPostPurchaseExperience();

  static Future<KlarnaPostPurchaseExperience> init(
      String locale, String purchaseCountry,
      {String? design,
      /** post purchase environment **/ KlarnaPostPurchaseEnvironment? environment}) async {
    var instance = KlarnaPostPurchaseExperience();
    await instance.initialize(locale, purchaseCountry,
        design: design, environment: environment);
    return instance;
  }

  Future<KlarnaResult> initialize(String locale, String purchaseCountry,
      {String? design,
      /** post purchase environment **/ KlarnaPostPurchaseEnvironment? environment}) async {
    final String result =
        await _channel.invokeMethod('initialize', <String, dynamic>{
      'id': _id,
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design,
      'sdkSource': KlarnaPostPurchaseEnvironmentHelper.getSdkSource(environment)
    });
    return KlarnaResult.fromJson(json.decode(result));
  }

  Future<Null> destroy() async {
    return await _channel.invokeMethod('destroy', <String, dynamic>{'id': _id});
  }

  Future<KlarnaResult> renderOperation(String operationToken,
      {String? locale}) async {
    final String result = await _channel.invokeMethod(
        'renderOperation', <String, dynamic>{
      'id': _id,
      'locale': locale,
      'operationToken': operationToken
    });
    return KlarnaResult.fromJson(json.decode(result));
  }

  Future<KlarnaResult> authorizationRequest(
      String clientId, String scope, String redirectUri,
      {String? locale,
      String? state,
      String? loginHint,
      String? responseType}) async {
    final String result =
        await _channel.invokeMethod('authorizationRequest', <String, dynamic>{
      'id': _id,
      'locale': locale,
      'clientId': clientId,
      'scope': scope,
      'redirectUri': redirectUri,
      'state': state,
      'loginHint': loginHint,
      'responseType': responseType
    });
    return KlarnaResult.fromJson(json.decode(result));
  }
}
