import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_environment.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_region.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_resource_endpoint.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_result.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_error.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_event_listener.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_render_result.dart';

class KlarnaPostPurchaseSDK {
  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_sdk');
  static const EventChannel _eventChannel =
      const EventChannel('klarna_post_purchase_sdk_events');

  static final _idRandom = Random.secure();

  var _id = _idRandom.nextInt(999999999);

  KlarnaPostPurchaseEventListener? eventListener;

  KlarnaPostPurchaseSDK._(KlarnaPostPurchaseEventListener? eventListener) {
    this.eventListener = eventListener;
    _setupEventListener();
  }

  static Future<KlarnaPostPurchaseSDK> createInstance(
      KlarnaPostPurchaseEventListener? eventListener,
      KlarnaEnvironment? environment,
      KlarnaRegion? region,
      KlarnaResourceEndpoint? resourceEndpoint) async {
    var instance = KlarnaPostPurchaseSDK._(eventListener);
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
    final String? result =
        await _channel.invokeMethod('initialize', <String, dynamic>{
      'id': _id,
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design,
    });
    return KlarnaResult.fromJsonString(result);
  }

  Future<KlarnaResult> authorizationRequest(
      String clientId, String scope, String redirectUri,
      {String? locale,
      String? state,
      String? loginHint,
      String? responseType}) async {
    final String? result =
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
    return KlarnaResult.fromJsonString(result);
  }

  Future<KlarnaResult> renderOperation(String operationToken,
      {String? locale, String? redirectUri}) async {
    final String? result =
        await _channel.invokeMethod('renderOperation', <String, dynamic>{
      'id': _id,
      'operationToken': operationToken,
      'locale': locale,
      'redirectUri': redirectUri
    });
    return KlarnaResult.fromJsonString(result);
  }

  Future<Null> destroy() async {
    return await _channel.invokeMethod('destroy', <String, dynamic>{'id': _id});
  }

  void _setupEventListener() {
    _eventChannel
        .receiveBroadcastStream()
        .map<String>((event) => event)
        .listen((p0) {
      final Map<String, dynamic> map = json.decode(p0);
      sendEventToListener(map);
    });
  }

  void sendEventToListener(Map<String, dynamic> eventMap) {
    final id = eventMap["id"];
    if (id == this._id) {
      final name = eventMap["name"];
      switch (name) {
        case "onInitialized":
          {
            eventListener?.onInitialized(this);
          }
          break;

        case "onAuthorizeRequested":
          {
            eventListener?.onAuthorizeRequested(this);
          }
          break;

        case "onRenderedOperation":
          {
            final renderResult = eventMap["renderResult"];
            switch (renderResult) {
              case "STATE_CHANGE":
                {
                  eventListener?.onRenderedOperation(
                      this, KlarnaPostPurchaseRenderResult.stateChange);
                }
                break;
              case "NO_STATE_CHANGE":
                {
                  eventListener?.onRenderedOperation(
                      this, KlarnaPostPurchaseRenderResult.noStateChange);
                }
                break;
            }
          }
          break;

        case "onError":
          {
            final errorMap = eventMap["error"] as Map<String, dynamic>;
            final KlarnaPostPurchaseError error = KlarnaPostPurchaseError(
                errorMap['name'],
                errorMap['message'],
                errorMap['status'],
                errorMap['isFatal']);
            eventListener?.onError(this, error);
          }
          break;

        default:
          {
            //statements;
          }
          break;
      }
    }
  }
}
