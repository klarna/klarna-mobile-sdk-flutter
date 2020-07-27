// General Event/Error callback to be used to send back arbitrary data and also error messages back to merchant

//Sample usage:

/*
KlarnaCallback.registerCallback(
    (event) {
      print("Got Event: $event");
    }, (error) {
      print("Got Error: $error");
    }
);
*/

import 'package:flutter/services.dart';

class KlarnaCallback {
  static const _eventChannel = const EventChannel('klarna_events');
  static const _errorChannel = const EventChannel('klarna_errors');

  Function(String) errorCallback;
  Function(String) eventCallback;

  Stream<String> _eventStream =
  _eventChannel.receiveBroadcastStream().map<String>((value) => value);
  Stream<String> _errorStream =
  _errorChannel.receiveBroadcastStream().map<String>((value) => value);

  KlarnaCallback(this.eventCallback, this.errorCallback);

  void onError(String error) {
    errorCallback?.call(error);
  }

  void onEvent(String event) {
    eventCallback?.call(event);
  }

  void _register() {
    _eventStream.listen(onEvent);
    _errorStream.listen(onError);
  }

  static Future<KlarnaCallback> registerCallback(
      Function(String) onEvent, Function(String) onError) async {
    KlarnaCallback klarnaCallback = new KlarnaCallback(onEvent, onError);
    klarnaCallback._register();
    return klarnaCallback;
  }
}
