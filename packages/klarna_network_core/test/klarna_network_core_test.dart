import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_core/src/messages.g.dart';

const _prefix = 'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final List<String> calls = [];
  // The decoded argument list of the most recent call to each method, so tests
  // can assert on the actual objects passed (not just that a call happened).
  final Map<String, List<Object?>> lastArgs = {};

  void mockChannel(String method, Object? Function(List<Object?> args) reply) {
    messenger.setMockMessageHandler('$_prefix.$method', (message) async {
      final args = KnCoreHostApi.pigeonChannelCodec.decodeMessage(message)
          as List<Object?>;
      calls.add('$method:${args.join(":")}');
      lastArgs[method] = args;
      return KnCoreHostApi.pigeonChannelCodec
          .encodeMessage(<Object?>[reply(args)]);
    });
  }

  // Makes a method's mock host reply with a Pigeon error, so tests can assert
  // the public API surfaces native failures.
  void mockChannelError(String method, String code, String msg) {
    messenger.setMockMessageHandler('$_prefix.$method', (message) async {
      return KnCoreHostApi.pigeonChannelCodec
          .encodeMessage(<Object?>[code, msg, null]);
    });
  }

  setUp(() {
    calls.clear();
    lastArgs.clear();
    // Reset the config cache so each test's initialize hits the native layer.
    Klarna.clearInstanceCache();
    mockChannel('initialize', (args) => null);
    mockChannel('getSessionToken', (args) => 'token-123');
    mockChannel('clearSession', (args) => null);
    mockChannel('setIntegrationMetadata', (args) => null);
    mockChannel('handleReturnUrl', (args) => true);
    mockChannel('dispose', (args) => null);
  });

  test('initialize creates an instance with a generated id', () async {
    final network = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'client', appReturnUrl: 'app://return'),
    );

    expect(network.instanceId, isNotEmpty);
    expect(calls.where((c) => c.startsWith('initialize:')), isNotEmpty);
  });

  test('getSessionToken / clearSession / dispose forward with the id',
      () async {
    final network = await Klarna.initializeWithInstanceId(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
      'inst-x',
    );
    calls.clear();

    final token = await network.network.session.token();
    await network.network.session.clear();
    await network.dispose();

    expect(token, 'token-123');
    expect(
        calls,
        containsAll(<String>[
          'getSessionToken:inst-x',
          'clearSession:inst-x',
          'dispose:inst-x',
        ]));
  });

  test('handleReturnUrl forwards the url', () async {
    final handled = await Klarna.handleReturnUrl('app://return?x=1');

    expect(handled, true);
    expect(calls, contains('handleReturnUrl:app://return?x=1'));
  });

  test('setIntegrationMetadata stores and forwards metadata', () async {
    final network = await Klarna.initializeWithInstanceId(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
      'inst-meta',
    );
    calls.clear();

    final metadata = KlarnaIntegrationMetadata(
      integrator: KlarnaIntegratorMetadata(
        name: 'FlutterExample',
        sessionReference: 'session-1',
        moduleName: 'checkout',
        moduleVersion: '1.0.0',
      ),
      originators: <KlarnaOriginatorMetadata>[
        KlarnaOriginatorMetadata(
          name: 'PartnerModule',
          sessionReference: 'origin-1',
        ),
      ],
    );

    network.setIntegrationMetadata(metadata);

    expect(network.integrationMetadata, metadata);
    expect(
      calls
          .where((call) => call.startsWith('setIntegrationMetadata:inst-meta')),
      isNotEmpty,
    );
  });

  test('initialize forwards the full configuration to the native layer',
      () async {
    await Klarna.initializeWithInstanceId(
      KlarnaConfiguration(
        clientId: 'client-1',
        appReturnUrl: 'app://return',
        accountId: 'acct-9',
        locale: 'en-US',
        klarnaNetworkSessionToken: 'session-token-7',
      ),
      'inst-cfg',
    );

    final args = lastArgs['initialize']!;
    expect(args[0], 'inst-cfg');
    final config = args[1] as KlarnaConfiguration;
    expect(config.clientId, 'client-1');
    expect(config.appReturnUrl, 'app://return');
    expect(config.accountId, 'acct-9');
    expect(config.locale, 'en-US');
    expect(config.klarnaNetworkSessionToken, 'session-token-7');
  });

  test('initialize honors an explicit instanceId', () async {
    final network = await Klarna.initializeWithInstanceId(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
      'my-fixed-id',
    );

    expect(network.instanceId, 'my-fixed-id');
  });

  test('distinct configurations create distinct instances', () async {
    final a = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c1', appReturnUrl: 'app://r'),
    );
    final b = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c2', appReturnUrl: 'app://r'),
    );

    expect(a.instanceId, isNotEmpty);
    expect(b.instanceId, isNotEmpty);
    expect(a.instanceId, isNot(b.instanceId));
    expect(identical(a, b), isFalse);
  });

  test('identical configuration returns the cached instance', () async {
    final a = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );
    calls.clear();
    final b = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );

    expect(identical(a, b), isTrue);
    // The second call is served from cache — no extra native initialize.
    expect(calls.where((c) => c.startsWith('initialize:')), isEmpty);
  });

  test('dispose evicts the cache so the next initialize re-creates', () async {
    final a = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );
    await a.dispose();
    calls.clear();
    final b = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );

    expect(identical(a, b), isFalse);
    expect(calls.where((c) => c.startsWith('initialize:')), isNotEmpty);
  });

  test('an explicit instanceId bypasses the cache', () async {
    final cached = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );
    final seamed = await Klarna.initializeWithInstanceId(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
      'inst-seam',
    );

    expect(identical(cached, seamed), isFalse);
    expect(seamed.instanceId, 'inst-seam');
  });

  test('integrationMetadata is null before being set', () async {
    final network = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );

    expect(network.integrationMetadata, isNull);
  });

  test('getSessionToken surfaces native errors', () async {
    final network = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );
    mockChannelError('getSessionToken', 'KlarnaNetworkCore', 'no session');

    expect(network.network.session.token(), throwsA(isA<PlatformException>()));
  });

  test('initialize surfaces native errors', () async {
    mockChannelError('initialize', 'KlarnaNetworkCore', 'bad client id');

    expect(
      Klarna.initialize(
        KlarnaConfiguration(clientId: 'bad', appReturnUrl: 'app://r'),
      ),
      throwsA(isA<PlatformException>()),
    );
  });
}
