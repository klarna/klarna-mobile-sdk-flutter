import 'dart:async';

import 'package:flutter/services.dart';

class KlarnaPostPurchaseExperience {

  static Function _eventCallback;
  static Function _errorCallback;

  static const MethodChannel _channel =
      const MethodChannel('klarna_post_purchase_experience');

  static const EventChannel _channel_events = 
      const EventChannel('klarna_post_purchase_experience_events');
  static Stream<String> _eventStream;

  static const EventChannel _channel_errors =
  const EventChannel('klarna_post_purchase_experience_errors');
  static Stream<String> _errorStream;

  static void setCallback(Function onEvent, Function onError){
    _eventCallback = onEvent;
    _errorCallback = onError;
    _eventStream = _channel_events.receiveBroadcastStream().map<String>((value) => value);
    _errorStream = _channel_errors.receiveBroadcastStream().map<String>((value) => value);
    _eventStream?.listen((event) { _eventCallback?.call(event); });
    _errorStream?.listen((error) { _errorCallback?.call(error); });
  }

  static Future<void> initialize(String locale, String purchaseCountry,
      {String design}) async {
    return await _channel.invokeMethod('initialize', <String, dynamic>{
      'locale': locale,
      'purchaseCountry': purchaseCountry,
      'design': design
    });
  }

  static Future<void> renderOperation(String operationToken,
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
