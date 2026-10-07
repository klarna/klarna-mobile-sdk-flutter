import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_core/src/messages.g.dart';

const _prefix = 'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('KlarnaTheme exposes stable wire values', () {
    expect(KlarnaTheme.light.wireValue, 'light');
    expect(KlarnaTheme.dark.wireValue, 'dark');
    expect(KlarnaTheme.automatic.wireValue, 'automatic');
  });

  test('Klarna button types expose stable wire values', () {
    expect(KlarnaButtonShape.roundedRect.wireValue, 'roundedRect');
    expect(KlarnaButtonShape.pill.wireValue, 'pill');
    expect(KlarnaButtonShape.rectangle.wireValue, 'rectangle');
    expect(KlarnaButtonStyle.filled.wireValue, 'filled');
    expect(KlarnaButtonStyle.outlined.wireValue, 'outlined');
    expect(KlarnaButtonState.default_.wireValue, 'default');
    expect(KlarnaButtonState.disabled.wireValue, 'disabled');
    expect(KlarnaButtonState.loading.wireValue, 'loading');
  });

  test('KlarnaSDKError carries the native error contract', () {
    const error = KlarnaSDKError(
      name: 'SDK_ERROR',
      message: 'Something went wrong',
      cause: 'details',
    );

    expect(error.name, 'SDK_ERROR');
    expect(error.message, 'Something went wrong');
    expect(error.cause, 'details');
    expect(error, isA<Exception>());
  });

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final List<String> calls = [];
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

  void mockChannelError(String method, String code, String msg) {
    messenger.setMockMessageHandler('$_prefix.$method', (message) async {
      return KnCoreHostApi.pigeonChannelCodec
          .encodeMessage(<Object?>[code, msg, null]);
    });
  }

  setUp(() {
    calls.clear();
    lastArgs.clear();
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

    await network.setIntegrationMetadata(metadata);

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

    expect(network.network.session.token(), throwsA(isA<KlarnaSDKError>()));
  });

  test('initialize surfaces native errors', () async {
    mockChannelError('initialize', 'KlarnaNetworkCore', 'bad client id');

    expect(
      Klarna.initialize(
        KlarnaConfiguration(clientId: 'bad', appReturnUrl: 'app://r'),
      ),
      throwsA(isA<KlarnaSDKError>()),
    );
  });

  test('a failed initialize does not poison the cache for the next attempt',
      () async {
    mockChannelError('initialize', 'KlarnaNetworkCore', 'bad client id');
    final configuration =
        KlarnaConfiguration(clientId: 'bad', appReturnUrl: 'app://r');

    await expectLater(
      Klarna.initialize(configuration),
      throwsA(isA<KlarnaSDKError>()),
    );
    await Future<void>.delayed(Duration.zero);

    mockChannel('initialize', (args) => null);
    final klarna = await Klarna.initialize(configuration);

    expect(klarna.instanceId, isNotEmpty);
  });

  test('setIntegrationMetadata surfaces native errors', () async {
    final network = await Klarna.initializeWithInstanceId(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
      'inst-meta-err',
    );
    mockChannelError(
        'setIntegrationMetadata', 'KlarnaNetworkCore', 'no instance found');

    expect(
      network.setIntegrationMetadata(
        KlarnaIntegrationMetadata(
          integrator: KlarnaIntegratorMetadata(
            name: 'FlutterExample',
            sessionReference: 'session-1',
          ),
        ),
      ),
      throwsA(isA<KlarnaSDKError>()),
    );
  });

  test(
      'concurrent initialize calls with the same config create only one '
      'native instance', () async {
    var initializeCalls = 0;
    mockChannel('initialize', (args) {
      initializeCalls++;
      return null;
    });

    final configuration =
        KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r');
    final results = await Future.wait(<Future<Klarna>>[
      Klarna.initialize(configuration),
      Klarna.initialize(configuration),
      Klarna.initialize(configuration),
    ]);

    expect(initializeCalls, 1);
    expect(identical(results[0], results[1]), isTrue);
    expect(identical(results[0], results[2]), isTrue);
  });

  test('handleReturnUrl surfaces native errors', () async {
    mockChannelError('handleReturnUrl', 'KlarnaNetworkCore', 'no instance');

    expect(
      Klarna.handleReturnUrl('app://return'),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.name, 'name', 'KlarnaNetworkCore')
          .having((error) => error.message, 'message', 'no instance')),
    );
  });

  test('clearSession surfaces native errors', () async {
    final network = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );
    mockChannelError('clearSession', 'KlarnaNetworkCore', 'no session');

    expect(
      network.network.session.clear(),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.name, 'name', 'KlarnaNetworkCore')),
    );
  });

  test('dispose surfaces native errors', () async {
    final network = await Klarna.initializeWithInstanceId(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
      'inst-dispose-err',
    );
    mockChannelError('dispose', 'KlarnaNetworkCore', 'no instance found');

    expect(
      network.dispose(),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.message, 'message', 'no instance found')),
    );
  });

  test('a native error without a message falls back to the error code',
      () async {
    final network = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );
    messenger.setMockMessageHandler(
      '$_prefix.getSessionToken',
      (message) async => KnCoreHostApi.pigeonChannelCodec
          .encodeMessage(<Object?>['KlarnaNetworkCore', null, null]),
    );

    expect(
      network.network.session.token(),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.message, 'message', 'KlarnaNetworkCore')),
    );
  });

  test('distinct acquiring configs create distinct instances', () async {
    final a = await Klarna.initialize(
      KlarnaConfiguration(
        clientId: 'c',
        appReturnUrl: 'app://r',
        acquiringConfig: KlarnaAcquiringConfig(
          paymentAccountReference: 'ref-1',
          paymentAcquiringAccountId: 'acct-1',
        ),
      ),
    );
    final b = await Klarna.initialize(
      KlarnaConfiguration(
        clientId: 'c',
        appReturnUrl: 'app://r',
        acquiringConfig: KlarnaAcquiringConfig(
          paymentAccountReference: 'ref-2',
          paymentAcquiringAccountId: 'acct-1',
        ),
      ),
    );

    expect(identical(a, b), isFalse);
  });

  test('an identical acquiring config returns the cached instance', () async {
    KlarnaConfiguration config() => KlarnaConfiguration(
          clientId: 'c',
          appReturnUrl: 'app://r',
          acquiringConfig: KlarnaAcquiringConfig(
            paymentAccountReference: 'ref-1',
            paymentAcquiringAccountId: 'acct-1',
          ),
        );

    final a = await Klarna.initialize(config());
    calls.clear();
    final b = await Klarna.initialize(config());

    expect(identical(a, b), isTrue);
    expect(calls.where((c) => c.startsWith('initialize:')), isEmpty);
  });

  test('disposing an explicit-id instance leaves the cache untouched',
      () async {
    final cached = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );
    final seamed = await Klarna.initializeWithInstanceId(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
      'inst-explicit',
    );

    await seamed.dispose();
    calls.clear();

    final again = await Klarna.initialize(
      KlarnaConfiguration(clientId: 'c', appReturnUrl: 'app://r'),
    );

    expect(identical(cached, again), isTrue);
    expect(calls.where((c) => c.startsWith('initialize:')), isEmpty);
  });
}
