import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_environment.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_error.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_event_listener.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_render_result.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_sdk.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_region.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_resource_endpoint.dart';

/// A listener that records callbacks for assertions.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('klarna_post_purchase_sdk');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // Captured (method, arguments) pairs for every invokeMethod on the channel.
  final List<MethodCall> calls = [];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  /// Returns the single captured call with the given [method].
  MethodCall callFor(String method) =>
      calls.firstWhere((c) => c.method == method);

  KlarnaPostPurchaseSDK newSdk([KlarnaPostPurchaseEventListener? listener]) {
    return KlarnaPostPurchaseSDK(
      listener ?? _RecordingListener(),
      'https://return.example',
      KlarnaEnvironment.PLAYGROUND,
      KlarnaRegion.EU,
      KlarnaResourceEndpoint.ALTERNATIVE_1,
    );
  }

  group('constructor -> create', () {
    test('sends create with mapped enum names and returnURL', () async {
      newSdk();
      await Future<void>.delayed(Duration.zero);

      final create = callFor('create');
      final args = create.arguments as Map;
      expect(args['returnURL'], 'https://return.example');
      expect(args['environment'], 'PLAYGROUND');
      expect(args['region'], 'EU');
      expect(args['resourceEndpoint'], 'ALTERNATIVE_1');
      expect(args['id'], isA<int>());
    });

    test('passes null for omitted optional enums', () async {
      KlarnaPostPurchaseSDK(
        _RecordingListener(),
        null,
        null,
        null,
        null,
      );
      await Future<void>.delayed(Duration.zero);

      final args = callFor('create').arguments as Map;
      expect(args['returnURL'], isNull);
      expect(args['environment'], isNull);
      expect(args['region'], isNull);
      expect(args['resourceEndpoint'], isNull);
    });

    test('each instance gets a distinct id', () async {
      final a = newSdk();
      final b = newSdk();
      await Future<void>.delayed(Duration.zero);

      final ids = calls
          .where((c) => c.method == 'create')
          .map((c) => (c.arguments as Map)['id'])
          .toList();
      expect(ids, hasLength(2));
      expect(ids[0], isNot(equals(ids[1])));
      // Sanity: the SDKs are distinct objects.
      expect(identical(a, b), isFalse);
    });
  });

  group('public methods forward to the channel', () {
    test('initialize sends locale, purchaseCountry and design', () async {
      final sdk = newSdk();
      calls.clear();

      sdk.initialize('en-US', 'US', design: 'titanium');
      await Future<void>.delayed(Duration.zero);

      final args = callFor('initialize').arguments as Map;
      expect(args['locale'], 'en-US');
      expect(args['purchaseCountry'], 'US');
      expect(args['design'], 'titanium');
      expect(args['id'], isA<int>());
    });

    test('initialize sends a null design when omitted', () async {
      final sdk = newSdk();
      calls.clear();

      sdk.initialize('sv-SE', 'SE');
      await Future<void>.delayed(Duration.zero);

      expect((callFor('initialize').arguments as Map)['design'], isNull);
    });

    test('authorizationRequest forwards all parameters', () async {
      final sdk = newSdk();
      calls.clear();

      sdk.authorizationRequest(
        'client-1',
        'scope-a',
        'app://redirect',
        locale: 'en-US',
        state: 'xyz',
        loginHint: 'user@example.com',
        responseType: 'code',
      );
      await Future<void>.delayed(Duration.zero);

      final args = callFor('authorizationRequest').arguments as Map;
      expect(args['clientId'], 'client-1');
      expect(args['scope'], 'scope-a');
      expect(args['redirectUri'], 'app://redirect');
      expect(args['locale'], 'en-US');
      expect(args['state'], 'xyz');
      expect(args['loginHint'], 'user@example.com');
      expect(args['responseType'], 'code');
    });

    test('renderOperation forwards token and optional args', () async {
      final sdk = newSdk();
      calls.clear();

      sdk.renderOperation('op-token',
          locale: 'de-DE', redirectUri: 'app://done');
      await Future<void>.delayed(Duration.zero);

      final args = callFor('renderOperation').arguments as Map;
      expect(args['operationToken'], 'op-token');
      expect(args['locale'], 'de-DE');
      expect(args['redirectUri'], 'app://done');
    });

    test('destroy sends only the id', () async {
      final sdk = newSdk();
      calls.clear();

      sdk.destroy();
      await Future<void>.delayed(Duration.zero);

      final args = callFor('destroy').arguments as Map;
      expect(args.keys, equals(['id']));
      expect(args['id'], isA<int>());
    });
  });
}
