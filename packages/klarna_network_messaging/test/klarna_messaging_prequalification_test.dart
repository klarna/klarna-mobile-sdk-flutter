import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_core/src/messages.g.dart' as core_messages;
import 'package:klarna_network_messaging/klarna_network_messaging.dart';
import 'package:klarna_network_messaging/src/messages.g.dart';

const _channel =
    'dev.flutter.pigeon.klarna_network_messaging.KnMessagingHostApi.prequalificationInitiate';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final codec = KnMessagingHostApi.pigeonChannelCodec;

  final List<List<Object?>> calls = [];

  void mockResult(KnPrequalificationResult result) {
    messenger.setMockMessageHandler(_channel, (ByteData? message) async {
      calls.add(codec.decodeMessage(message)! as List<Object?>);
      return codec.encodeMessage(<Object?>[result]);
    });
  }

  void mockError(String code, String errorMessage) {
    messenger.setMockMessageHandler(_channel, (ByteData? request) async {
      calls.add(codec.decodeMessage(request)! as List<Object?>);
      return codec.encodeMessage(<Object?>[code, errorMessage, null]);
    });
  }

  late KlarnaMessaging messaging;

  setUp(() {
    calls.clear();
    messaging = KlarnaMessaging.test(instanceId: 'inst-1');
  });

  tearDown(() => messenger.setMockMessageHandler(_channel, null));

  const data = KlarnaMessagingPrequalificationData(
    amount: 9999,
    currency: 'USD',
  );

  test('sends the instance id and data to the host API', () async {
    mockResult(KnPrequalificationResult(
      status: KnPrequalificationStatus.aborted,
    ));

    await messaging.prequalification.initiate(data);

    expect(calls, hasLength(1));
    expect(calls.single[0], 'inst-1');
    final sent = calls.single[1]! as KnPrequalificationData;
    expect(sent.amount, 9999);
    expect(sent.currency, 'USD');
  });

  test('approved maps to Approved with a UTC expiresAt', () async {
    const millis = 1798761600000; // 2027-01-01T00:00:00Z
    mockResult(KnPrequalificationResult(
      status: KnPrequalificationStatus.approved,
      expiresAtMillis: millis,
    ));

    final result = await messaging.prequalification.initiate(data);

    expect(result, isA<KlarnaMessagingPrequalificationApproved>());
    final expiresAt =
        (result as KlarnaMessagingPrequalificationApproved).expiresAt;
    expect(expiresAt, DateTime.utc(2027, 1, 1));
    expect(expiresAt.isUtc, isTrue);
    expect(expiresAt.millisecondsSinceEpoch, millis);
  });

  test('aborted maps to Aborted', () async {
    mockResult(KnPrequalificationResult(
      status: KnPrequalificationStatus.aborted,
    ));

    final result = await messaging.prequalification.initiate(data);

    expect(result, isA<KlarnaMessagingPrequalificationAborted>());
  });

  test('result can be matched exhaustively', () async {
    mockResult(KnPrequalificationResult(
      status: KnPrequalificationStatus.aborted,
    ));

    final result = await messaging.prequalification.initiate(data);
    final label = switch (result) {
      KlarnaMessagingPrequalificationApproved(:final expiresAt) =>
        'approved $expiresAt',
      KlarnaMessagingPrequalificationAborted() => 'aborted',
    };

    expect(label, 'aborted');
  });

  for (final name in ['OPERATION_FAILED', 'INITIATE_ALREADY_IN_PROGRESS']) {
    test('PlatformException $name maps to KlarnaSDKError', () async {
      mockError(name, 'boom');

      await expectLater(
        messaging.prequalification.initiate(data),
        throwsA(
          isA<KlarnaSDKError>()
              .having((e) => e.name, 'name', name)
              .having((e) => e.message, 'message', 'boom'),
        ),
      );
    });
  }

  group('validation', () {
    setUp(() {
      mockResult(KnPrequalificationResult(
        status: KnPrequalificationStatus.aborted,
      ));
    });

    test('rejects a zero amount without calling the host', () async {
      await expectLater(
        messaging.prequalification.initiate(
          const KlarnaMessagingPrequalificationData(
            amount: 0,
            currency: 'USD',
          ),
        ),
        throwsArgumentError,
      );
      expect(calls, isEmpty);
    });

    test('rejects a negative amount', () async {
      await expectLater(
        messaging.prequalification.initiate(
          const KlarnaMessagingPrequalificationData(
            amount: -1,
            currency: 'USD',
          ),
        ),
        throwsArgumentError,
      );
      expect(calls, isEmpty);
    });

    test('rejects an empty currency', () async {
      await expectLater(
        messaging.prequalification.initiate(
          const KlarnaMessagingPrequalificationData(
            amount: 100,
            currency: '',
          ),
        ),
        throwsArgumentError,
      );
      expect(calls, isEmpty);
    });

    test('rejects a whitespace-only currency', () async {
      await expectLater(
        messaging.prequalification.initiate(
          const KlarnaMessagingPrequalificationData(
            amount: 100,
            currency: '   ',
          ),
        ),
        throwsArgumentError,
      );
      expect(calls, isEmpty);
    });
  });

  group('klarna.messaging extension', () {
    late Klarna klarna;

    setUpAll(() async {
      final coreCodec = core_messages.KnCoreHostApi.pigeonChannelCodec;
      messenger.setMockMessageHandler(
        'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi.initialize',
        (message) async => coreCodec.encodeMessage(<Object?>[null]),
      );
      klarna = await Klarna.initializeWithInstanceId(
        KlarnaConfiguration(
          clientId: 'client-id',
          appReturnUrl: 'app://return',
        ),
        'msg-ext',
      );
    });

    tearDownAll(() {
      messenger.setMockMessageHandler(
        'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi.initialize',
        null,
      );
    });

    test('returns the same messaging object for the same instance', () {
      expect(identical(klarna.messaging, klarna.messaging), isTrue);
      expect(
        identical(
          klarna.messaging.prequalification,
          klarna.messaging.prequalification,
        ),
        isTrue,
      );
    });

    test('binds the messaging object to the instance id', () {
      // ignore: invalid_use_of_internal_member
      expect(klarna.messaging.instanceId, 'msg-ext');
    });

    test('creates distinct messaging objects for distinct instances', () async {
      final other = await Klarna.initializeWithInstanceId(
        KlarnaConfiguration(
          clientId: 'client-id',
          appReturnUrl: 'app://return',
        ),
        'msg-ext-2',
      );

      expect(identical(klarna.messaging, other.messaging), isFalse);
    });

    test('initiate through the extension routes with the instance id',
        () async {
      mockResult(KnPrequalificationResult(
        status: KnPrequalificationStatus.aborted,
      ));

      await klarna.messaging.prequalification.initiate(data);

      expect(calls.single[0], 'msg-ext');
    });
  });
}
