import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_environment.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_region.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_resource_endpoint.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_result.dart';

class KlarnaPostPurchaseSDK {
  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_sdk');

  static final _idRandom = Random.secure();

  var _id = _idRandom.nextInt(999999999);

  KlarnaPostPurchaseSDK._();

  static Future<KlarnaPostPurchaseSDK> createInstance(
      KlarnaEnvironment? environment,
      KlarnaRegion? region,
      KlarnaResourceEndpoint? resourceEndpoint) async {
    var instance = KlarnaPostPurchaseSDK._();
    await instance._construct(environment, region, resourceEndpoint);
    return instance;
  }

  Future<void> _construct(KlarnaEnvironment? environment, KlarnaRegion? region,
      KlarnaResourceEndpoint? resourceEndpoint) async {
    String? environmentName;
    if (environment != null) {
      environmentName = describeEnum(environment);
    }
    String? regionName;
    if (region != null) {
      regionName = describeEnum(region);
    }
    String? resourceEndpointName;
    if (resourceEndpoint != null) {
      resourceEndpointName = describeEnum(resourceEndpoint);
    }
    await _channel.invokeMethod('create', <String, dynamic>{
      'id': _id,
      'environment': environmentName,
      'region': regionName,
      'resourceEndpoint': resourceEndpointName
    }).onError((error, stackTrace) => {});
    return null;
  }

  Future<KlarnaResult> initialize(String locale, String purchaseCountry,
      {String? design}) async {
    final String result =
        await _channel.invokeMethod('initialize', <String, dynamic>{
      'id': _id,
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design,
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
      'clientId': clientId,
      'scope': scope,
      'redirectUri': redirectUri,
      'locale': locale,
      'state': state,
      'loginHint': loginHint,
      'responseType': responseType
    });
    return KlarnaResult.fromJson(json.decode(result));
  }

  Future<KlarnaResult> renderOperation(String operationToken,
      {String? locale, String? redirectUri}) async {
    final String result =
        await _channel.invokeMethod('renderOperation', <String, dynamic>{
      'id': _id,
      'operationToken': operationToken,
      'locale': locale,
      'redirectUri': redirectUri
    });
    return KlarnaResult.fromJson(json.decode(result));
  }

  Future<Null> destroy() async {
    return await _channel.invokeMethod('destroy', <String, dynamic>{'id': _id});
  }
}
