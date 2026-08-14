import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_environment.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_error.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_event_listener.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_render_result.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_sdk.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_region.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_resource_endpoint.dart';

class _RecordingListener implements KlarnaPostPurchaseEventListener {
  int initialized = 0;
  int authorizeRequested = 0;
  final List<KlarnaPostPurchaseRenderResult> rendered = [];
  final List<KlarnaPostPurchaseError> errors = [];

  @override
  void onInitialized(KlarnaPostPurchaseSDK sdk) => initialized++;

  @override
  void onAuthorizeRequested(KlarnaPostPurchaseSDK sdk) => authorizeRequested++;

  @override
  void onRenderedOperation(
      KlarnaPostPurchaseSDK sdk, KlarnaPostPurchaseRenderResult result) {
    rendered.add(result);
  }

  @override
  void onError(KlarnaPostPurchaseSDK sdk, KlarnaPostPurchaseError error) {
    errors.add(error);
  }
}

/// A mock EventChannel stream handler that hands back an [EventSink] on listen,
/// letting tests push events into the live stream the SDK subscribes to.
class _CapturingStreamHandler extends MockStreamHandler {
  MockStreamHandlerEventSink? _sink;

  void emit(dynamic event) => _sink?.success(event);

  @override
  void onListen(dynamic arguments, MockStreamHandlerEventSink events) {
    _sink = events;
  }

  @override
  void onCancel(dynamic arguments) {
    _sink = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('klarna_post_purchase_sdk');
  const eventChannel = EventChannel('klarna_post_purchase_sdk_events');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // The SDK's event listener is a process-wide singleton that subscribes to the
  // EventChannel exactly once. We register one mock stream handler for the whole
  // suite and capture its sink, so every test pushes events through the same
  // live subscription the singleton is actually listening to.
  late _CapturingStreamHandler streamHandler;

  setUpAll(() {
    streamHandler = _CapturingStreamHandler();
    messenger.setMockStreamHandler(eventChannel, streamHandler);
  });

  tearDownAll(() {
    messenger.setMockStreamHandler(eventChannel, null);
  });

  setUp(() {
    // Swallow method-channel calls (the constructor calls `create`).
    messenger.setMockMethodCallHandler(methodChannel, (_) async => null);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
  });

  /// Lets the broadcast-stream `.listen` callback run after an event is pushed.
  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 1));

  /// Pushes a raw event (the native side sends a JSON string) through the
  /// EventChannel's stream, then waits for the listener to process it.
  Future<void> emit(Map<String, dynamic> event) async {
    streamHandler.emit(json.encode(event));
    await pump();
  }

  test('onInitialized is routed to the matching SDK', () async {
    final listener = _RecordingListener();
    late int id;
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      if (call.method == 'create') id = (call.arguments as Map)['id'] as int;
      return null;
    });
    KlarnaPostPurchaseSDK(listener, null, KlarnaEnvironment.PLAYGROUND,
        KlarnaRegion.EU, KlarnaResourceEndpoint.ALTERNATIVE_1);
    await pump();

    await emit({'id': id, 'name': 'onInitialized'});

    expect(listener.initialized, 1);
    expect(listener.authorizeRequested, 0);
  });

  test('onAuthorizeRequested is routed to the matching SDK', () async {
    final listener = _RecordingListener();
    late int id;
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      if (call.method == 'create') id = (call.arguments as Map)['id'] as int;
      return null;
    });
    KlarnaPostPurchaseSDK(listener, null, KlarnaEnvironment.PLAYGROUND,
        KlarnaRegion.EU, KlarnaResourceEndpoint.ALTERNATIVE_1);
    await pump();

    await emit({'id': id, 'name': 'onAuthorizeRequested'});

    expect(listener.authorizeRequested, 1);
  });

  test('onRenderedOperation maps STATE_CHANGE and NO_STATE_CHANGE', () async {
    final listener = _RecordingListener();
    late int id;
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      if (call.method == 'create') id = (call.arguments as Map)['id'] as int;
      return null;
    });
    KlarnaPostPurchaseSDK(listener, null, KlarnaEnvironment.PLAYGROUND,
        KlarnaRegion.EU, KlarnaResourceEndpoint.ALTERNATIVE_1);
    await pump();

    await emit({
      'id': id,
      'name': 'onRenderedOperation',
      'renderResult': 'STATE_CHANGE'
    });
    await emit({
      'id': id,
      'name': 'onRenderedOperation',
      'renderResult': 'NO_STATE_CHANGE'
    });

    expect(listener.rendered, [
      KlarnaPostPurchaseRenderResult.stateChange,
      KlarnaPostPurchaseRenderResult.noStateChange,
    ]);
  });

  test('onError parses the error map into a KlarnaPostPurchaseError', () async {
    final listener = _RecordingListener();
    late int id;
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      if (call.method == 'create') id = (call.arguments as Map)['id'] as int;
      return null;
    });
    KlarnaPostPurchaseSDK(listener, null, KlarnaEnvironment.PLAYGROUND,
        KlarnaRegion.EU, KlarnaResourceEndpoint.ALTERNATIVE_1);
    await pump();

    await emit({
      'id': id,
      'name': 'onError',
      'error': {
        'name': 'NetworkError',
        'message': 'timed out',
        'status': '504',
        'isFatal': true,
      }
    });

    expect(listener.errors, hasLength(1));
    final error = listener.errors.single;
    expect(error.name, 'NetworkError');
    expect(error.message, 'timed out');
    expect(error.status, '504');
    expect(error.isFatal, true);
  });

  test('events for an unknown id are not delivered', () async {
    final listener = _RecordingListener();
    messenger.setMockMethodCallHandler(methodChannel, (_) async => null);
    KlarnaPostPurchaseSDK(listener, null, KlarnaEnvironment.PLAYGROUND,
        KlarnaRegion.EU, KlarnaResourceEndpoint.ALTERNATIVE_1);
    await pump();

    await emit({'id': -1, 'name': 'onInitialized'});

    expect(listener.initialized, 0);
  });

  test('an unknown event name is ignored', () async {
    final listener = _RecordingListener();
    late int id;
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      if (call.method == 'create') id = (call.arguments as Map)['id'] as int;
      return null;
    });
    KlarnaPostPurchaseSDK(listener, null, KlarnaEnvironment.PLAYGROUND,
        KlarnaRegion.EU, KlarnaResourceEndpoint.ALTERNATIVE_1);
    await pump();

    await emit({'id': id, 'name': 'somethingUnsupported'});

    expect(listener.initialized, 0);
    expect(listener.authorizeRequested, 0);
    expect(listener.rendered, isEmpty);
    expect(listener.errors, isEmpty);
  });
}
