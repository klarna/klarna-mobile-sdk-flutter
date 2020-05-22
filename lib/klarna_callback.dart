// General Event/Error callback to be used to send back arbitrary data and also error messages back to merchant

//Sample usage:

/*class X {
  static KlarnaCallback _callback;
  static const EventChannel _channel_events =
  const EventChannel('klarna_events');
  static Stream<String> _eventStream;

  static const EventChannel _channel_errors =
  const EventChannel('klarna_errors');
  static Stream<String> _errorStream;
  static void setCallback(Function onEvent, Function onError){
    _callback = KlarnaCallback(onEvent, onError);
    _eventStream = _channel_events.receiveBroadcastStream().map<String>((value) => value);
    _errorStream = _channel_errors.receiveBroadcastStream().map<String>((value) => value);
    _eventStream?.listen((event) { _callback.onEvent(event); });
    _errorStream?.listen((error) { _callback.onError(error); });
  }
}

X.setCallback(
      (event) {
      print("Got Event: $event");
      },
      (error) {
      print("Got Error: $error");
    });
*/

class KlarnaCallback {

  Function(String) errorCallback;
  Function(String) eventCallback;

  KlarnaCallback(this.eventCallback, this.errorCallback);

  void onError(String error){
      errorCallback?.call(error);
  }

  void onEvent(String event){
      eventCallback?.call(event);
  }
}