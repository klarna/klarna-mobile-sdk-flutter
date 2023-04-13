import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_environment.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_error.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_event_listener.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_render_result.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_region.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_resource_endpoint.dart';

class KlarnaPostPurchaseSDK {
  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_sdk');

  static final _idRandom = Random.secure();

  final _id = _idRandom.nextInt(999999999);

  final KlarnaPostPurchaseEventListener eventListener;

  KlarnaPostPurchaseSDK(
      this.eventListener,
      String? returnUrl,
      KlarnaEnvironment? environment,
      KlarnaRegion? region,
      KlarnaResourceEndpoint? resourceEndpoint) {
    _KlarnaPostPurchaseEventChannelListener.getInstance().registerSDK(this);
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
    _channel.invokeMethod('create', <String, dynamic>{
      'id': _id,
      'returnURL': returnUrl,
      'environment': environmentName,
      'region': regionName,
      'resourceEndpoint': resourceEndpointName
    }).onError((error, stackTrace) => {});
  }

  void initialize(String locale, String purchaseCountry,
      {String? design}) async {
    await _channel.invokeMethod('initialize', <String, dynamic>{
      'id': _id,
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design,
    });
  }

  void authorizationRequest(String clientId, String scope, String redirectUri,
      {String? locale,
      String? state,
      String? loginHint,
      String? responseType}) async {
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
  }

  void renderOperation(String operationToken,
      {String? locale, String? redirectUri}) async {
    await _channel.invokeMethod('renderOperation', <String, dynamic>{
      'id': _id,
      'operationToken': operationToken,
      'locale': locale,
      'redirectUri': redirectUri
    });
  }

  void destroy() async {
    await _channel.invokeMethod('destroy', <String, dynamic>{'id': _id});
  }
}

class _KlarnaPostPurchaseEventChannelListener {
  static const EventChannel _eventChannel =
      const EventChannel('klarna_post_purchase_sdk_events');

  static _KlarnaPostPurchaseEventChannelListener? instance;

  static _KlarnaPostPurchaseEventChannelListener getInstance() {
    final current = instance;
    if (current == null) {
      final listener = new _KlarnaPostPurchaseEventChannelListener._();
      instance = listener;
      return listener;
    } else {
      return current;
    }
  }

  List<WeakReference<KlarnaPostPurchaseSDK>> _postPurchaseSDKList = [];

  _KlarnaPostPurchaseEventChannelListener._() {
    _setupEventListener();
  }

  void registerSDK(KlarnaPostPurchaseSDK postPurchaseSDK) {
    _postPurchaseSDKList.add(new WeakReference(postPurchaseSDK));
  }

  void _setupEventListener() {
    _eventChannel
        .receiveBroadcastStream()
        .map<String>((event) => event)
        .listen((p0) {
      final Map<String, dynamic> map = json.decode(p0);
      _processEvent(map);
    });
  }

  Iterable<KlarnaPostPurchaseSDK?>? findSDK(int id) {
    final items =
        _postPurchaseSDKList.where((element) => element.target?._id == id);
    return items.map((e) => e.target);
  }

  void _processEvent(Map<String, dynamic> eventMap) {
    final id = eventMap["id"];
    final sdks = findSDK(id);
    sdks?.forEach((sdk) {
      final eventListener = sdk?.eventListener;
      if (sdk != null && eventListener != null) {
        _sendEventToListener(sdk, eventListener, eventMap);
      }
    });
  }

  void _sendEventToListener(
      KlarnaPostPurchaseSDK sdk,
      KlarnaPostPurchaseEventListener eventListener,
      Map<String, dynamic> eventMap) {
    final name = eventMap["name"];
    switch (name) {
      case "onInitialized":
        {
          eventListener.onInitialized(sdk);
        }
        break;

      case "onAuthorizeRequested":
        {
          eventListener.onAuthorizeRequested(sdk);
        }
        break;

      case "onRenderedOperation":
        {
          final renderResult = eventMap["renderResult"];
          switch (renderResult) {
            case "STATE_CHANGE":
              {
                eventListener.onRenderedOperation(
                    sdk, KlarnaPostPurchaseRenderResult.stateChange);
              }
              break;
            case "NO_STATE_CHANGE":
              {
                eventListener.onRenderedOperation(
                    sdk, KlarnaPostPurchaseRenderResult.noStateChange);
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
          eventListener.onError(sdk, error);
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
