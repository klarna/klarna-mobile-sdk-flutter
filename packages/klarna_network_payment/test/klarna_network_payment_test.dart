import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_core/src/messages.g.dart' as core_messages;
import 'package:klarna_network_payment/klarna_network_payment.dart';
import 'package:klarna_network_payment/src/klarna_payment_events.dart';
import 'package:klarna_network_payment/src/messages.g.dart';

const _prefix = 'dev.flutter.pigeon.klarna_network_payment.KnPaymentHostApi';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final List<String> calls = [];

  void mockChannel(String method, Object? Function(List<Object?> args) reply) {
    final channelName = '$_prefix.$method';
    messenger.setMockMessageHandler(channelName, (ByteData? message) async {
      final args = KnPaymentHostApi.pigeonChannelCodec.decodeMessage(message)
          as List<Object?>;
      calls.add('$method:${args.join(":")}');
      return KnPaymentHostApi.pigeonChannelCodec
          .encodeMessage(<Object?>[reply(args)]);
    });
  }

  void mockErrorChannel(String method, String code, String message) {
    final channelName = '$_prefix.$method';
    messenger.setMockMessageHandler(channelName, (ByteData? data) async {
      final args = KnPaymentHostApi.pigeonChannelCodec.decodeMessage(data)
          as List<Object?>;
      calls.add('$method:${args.join(":")}');
      return KnPaymentHostApi.pigeonChannelCodec
          .encodeMessage(<Object?>[code, message, null]);
    });
  }

  late KlarnaPayment payment;

  setUp(() {
    calls.clear();
    payment = KlarnaPayment.test(instanceId: 'inst-1');

    mockChannel(
        'initiateWithId',
        (args) => KlarnaPaymentRequest(
            paymentRequestId: args[1]! as String,
            state: KlarnaPaymentRequestState.submitted));
    mockChannel(
        'initiateWithData',
        (args) => KlarnaPaymentRequest(
            paymentRequestId: 'generated',
            state: KlarnaPaymentRequestState.submitted));
    mockChannel(
        'fetch',
        (args) => KlarnaPaymentRequest(
            paymentRequestId: args[1]! as String,
            state: KlarnaPaymentRequestState.completed));
    mockChannel(
        'cancel',
        (args) => KlarnaPaymentRequest(
            paymentRequestId: args[1]! as String,
            state: KlarnaPaymentRequestState.canceled));
    mockChannel(
        'presentationFetch',
        (args) => KlarnaPaymentPresentationContent(
            instruction: KlarnaPaymentPresentationInstruction.showKlarna,
            paymentOption: KlarnaPaymentPresentationPaymentOption(
                paymentOptionId: 'pay-now')));
    mockChannel(
        'presentationHandleLink',
        (args) => KlarnaPaymentPresentationContent(
            instruction: KlarnaPaymentPresentationInstruction.showKlarna));
  });

  test('initiate with an id forwards to initiateWithId', () async {
    final result = await payment.initiate('pr-123');

    expect(result.paymentRequestId, 'pr-123');
    expect(result.state, KlarnaPaymentRequestState.submitted);
    expect(calls, contains('initiateWithId:inst-1:pr-123'));
  });

  test('initiate with data forwards to initiateWithData', () async {
    final result = await payment
        .initiate(KlarnaPaymentRequestData(currency: 'EUR', amount: 1000));

    expect(result.state, KlarnaPaymentRequestState.submitted);
    expect(calls.where((c) => c.startsWith('initiateWithData:inst-1')),
        isNotEmpty);
  });

  test('initiate with an unsupported type throws ArgumentError', () {
    expect(() => payment.initiate(42), throwsArgumentError);
  });

  test('fetch / cancel forward with the instance id', () async {
    final fetched = await payment.fetch('pr-1');
    final cancelled = await payment.cancel('pr-2');

    expect(fetched.state, KlarnaPaymentRequestState.completed);
    expect(cancelled.state, KlarnaPaymentRequestState.canceled);
    expect(
        calls,
        containsAll(<String>[
          'fetch:inst-1:pr-1',
          'cancel:inst-1:pr-2',
        ]));
  });

  test('presentation fetch / handleLink forward to the host api', () async {
    await payment.presentation
        .fetch(KlarnaPaymentPresentationData(currency: 'USD', amount: 500));
    await payment.presentation.handleLink('app://return');

    expect(calls.where((c) => c.startsWith('presentationFetch:inst-1')),
        isNotEmpty);
    expect(calls, contains('presentationHandleLink:inst-1:app://return'));
  });

  test('host api failures throw KlarnaSDKError', () async {
    mockErrorChannel('fetch', 'SDK_ERROR', 'Fetch failed');

    await expectLater(
      payment.fetch('pr-error'),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.name, 'name', 'SDK_ERROR')
          .having((error) => error.message, 'message', 'Fetch failed')),
    );
  });

  test('presentation failures throw KlarnaSDKError', () async {
    mockErrorChannel('presentationHandleLink', 'PRESENTATION', 'No content');

    await expectLater(
      payment.presentation.handleLink('app://return'),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.name, 'name', 'PRESENTATION')
          .having((error) => error.message, 'message', 'No content')),
    );
  });

  group('button press routing', () {
    final dispatcher = KlarnaPaymentEventDispatcher.instance;

    test('invokes the callback registered for the pressed view id', () {
      var pressed = 0;
      dispatcher.registerButtonPressed(1, () => pressed++);
      addTearDown(() => dispatcher.unregisterButtonPressed(1));

      dispatcher.onButtonPressed(1);

      expect(pressed, 1);
    });

    test('routes each press only to its own view id', () {
      final pressed = <int>[];
      dispatcher.registerButtonPressed(1, () => pressed.add(1));
      dispatcher.registerButtonPressed(2, () => pressed.add(2));
      addTearDown(() {
        dispatcher.unregisterButtonPressed(1);
        dispatcher.unregisterButtonPressed(2);
      });

      dispatcher.onButtonPressed(2);
      dispatcher.onButtonPressed(1);
      dispatcher.onButtonPressed(2);

      expect(pressed, [2, 1, 2]);
    });

    test('does nothing for an unregistered view id', () {
      expect(() => dispatcher.onButtonPressed(999), returnsNormally);
    });

    test('unregister stops further callbacks', () {
      var pressed = 0;
      dispatcher.registerButtonPressed(3, () => pressed++);
      dispatcher.onButtonPressed(3);
      dispatcher.unregisterButtonPressed(3);
      dispatcher.onButtonPressed(3);

      expect(pressed, 1);
    });

    test('re-registering replaces the previous callback', () {
      var first = 0;
      var second = 0;
      dispatcher.registerButtonPressed(4, () => first++);
      dispatcher.registerButtonPressed(4, () => second++);
      addTearDown(() => dispatcher.unregisterButtonPressed(4));

      dispatcher.onButtonPressed(4);

      expect(first, 0);
      expect(second, 1);
    });
  });

  group('button height clamping', () {
    // The native button enforces its own minimum in onMeasure, so a shorter
    // Flutter slot leaves the native view measuring taller than the space
    // reserved for it and the overflow gets clipped. The widget therefore
    // floors the height it lays out (and reports to native) at that minimum.
    late Klarna klarna;

    setUpAll(() async {
      final codec = core_messages.KnCoreHostApi.pigeonChannelCodec;
      messenger.setMockMessageHandler(
        'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi.initialize',
        (message) async => codec.encodeMessage(<Object?>[null]),
      );
      klarna = await Klarna.initializeWithInstanceId(
        KlarnaConfiguration(
          clientId: 'client-id',
          appReturnUrl: 'app://return',
        ),
        'i1',
      );
    });

    tearDownAll(() {
      messenger.setMockMessageHandler(
        'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi.initialize',
        null,
      );
    });

    Future<double> laidOutHeight(
      WidgetTester tester, {
      required double requested,
    }) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: KlarnaPaymentButton(
            instance: klarna,
            onPressed: () {},
            height: requested,
          ),
        ),
      ));
      return tester.getSize(find.byType(KlarnaPaymentButton)).height;
    }

    testWidgets('raises a below-minimum height to the minimum', (tester) async {
      expect(
        await laidOutHeight(tester, requested: 32),
        56,
      );
    });

    testWidgets('leaves an above-minimum height untouched', (tester) async {
      expect(await laidOutHeight(tester, requested: 72), 72);
    });

    testWidgets('defaults to the minimum', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: KlarnaPaymentButton(instance: klarna, onPressed: () {}),
        ),
      ));
      expect(
        tester.getSize(find.byType(KlarnaPaymentButton)).height,
        56,
      );
    });
  });

  test('initiate failures throw KlarnaSDKError', () async {
    mockErrorChannel('initiateWithId', 'INITIATE', 'bad request');

    await expectLater(
      payment.initiate('pr-bad'),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.name, 'name', 'INITIATE')
          .having((error) => error.message, 'message', 'bad request')),
    );

    mockErrorChannel('initiateWithData', 'INITIATE_DATA', 'bad data');

    await expectLater(
      payment.initiate(KlarnaPaymentRequestData(currency: 'EUR', amount: 100)),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.name, 'name', 'INITIATE_DATA')),
    );
  });

  test('cancel failures throw KlarnaSDKError', () async {
    mockErrorChannel('cancel', 'CANCEL', 'cannot cancel');

    await expectLater(
      payment.cancel('pr-x'),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.name, 'name', 'CANCEL')
          .having((error) => error.message, 'message', 'cannot cancel')),
    );
  });

  test('initiate ArgumentError names the unsupported type', () {
    expect(
      () => payment.initiate(42),
      throwsA(isA<ArgumentError>()
          .having((e) => e.message, 'message', contains('got int'))),
    );
  });

  test('presentation fetch failures throw KlarnaSDKError', () async {
    mockErrorChannel('presentationFetch', 'PRESENTATION', 'fetch failed');

    await expectLater(
      payment.presentation
          .fetch(KlarnaPaymentPresentationData(currency: 'USD', amount: 500)),
      throwsA(isA<KlarnaSDKError>()
          .having((error) => error.name, 'name', 'PRESENTATION')),
    );
  });

  group('klarna.payment extension', () {
    late Klarna klarna;

    setUpAll(() async {
      final codec = core_messages.KnCoreHostApi.pigeonChannelCodec;
      messenger.setMockMessageHandler(
        'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi.initialize',
        (message) async => codec.encodeMessage(<Object?>[null]),
      );
      klarna = await Klarna.initializeWithInstanceId(
        KlarnaConfiguration(
          clientId: 'client-id',
          appReturnUrl: 'app://return',
        ),
        'inst-ext',
      );
    });

    tearDownAll(() {
      messenger.setMockMessageHandler(
        'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi.initialize',
        null,
      );
    });

    test('returns the same payment object for the same instance', () {
      expect(identical(klarna.payment, klarna.payment), isTrue);
    });

    test('binds the payment to the instance id', () {
      // ignore: invalid_use_of_internal_member
      expect(klarna.payment.instanceId, 'inst-ext');
    });

    test('creates distinct payments for distinct instances', () async {
      final other = await Klarna.initializeWithInstanceId(
        KlarnaConfiguration(
          clientId: 'client-id',
          appReturnUrl: 'app://return',
        ),
        'inst-ext-2',
      );

      expect(identical(klarna.payment, other.payment), isFalse);
    });

    test('presentation is a stable accessor', () {
      final payment = klarna.payment;

      expect(identical(payment.presentation, payment.presentation), isTrue);
    });
  });

  test('KlarnaPaymentButtonIntent exposes stable wire values', () {
    expect(KlarnaPaymentButtonIntent.pay.wireValue, 'pay');
    expect(KlarnaPaymentButtonIntent.subscribe.wireValue, 'subscribe');
    expect(KlarnaPaymentButtonIntent.addToWallet.wireValue, 'addToWallet');
  });

  test('payment button configuration differs when any field differs', () {
    const base = KlarnaPaymentButtonConfiguration();

    expect(
      base,
      isNot(const KlarnaPaymentButtonConfiguration(
          state: KlarnaButtonState.loading)),
    );
    expect(
      base,
      isNot(const KlarnaPaymentButtonConfiguration(
          intent: KlarnaPaymentButtonIntent.pay)),
    );
    expect(
      base,
      isNot(const KlarnaPaymentButtonConfiguration(
          shape: KlarnaButtonShape.pill)),
    );
    expect(
      base,
      isNot(const KlarnaPaymentButtonConfiguration(
          style: KlarnaButtonStyle.outlined)),
    );
    expect(
      base,
      isNot(const KlarnaPaymentButtonConfiguration(theme: KlarnaTheme.dark)),
    );
    expect(base, isNot(Object()));
  });

  test('payment button configuration uses native button types', () {
    const a = KlarnaPaymentButtonConfiguration(
      state: KlarnaButtonState.loading,
      intent: KlarnaPaymentButtonIntent.pay,
      shape: KlarnaButtonShape.pill,
      style: KlarnaButtonStyle.outlined,
      theme: KlarnaTheme.dark,
    );
    const b = KlarnaPaymentButtonConfiguration(
      state: KlarnaButtonState.loading,
      intent: KlarnaPaymentButtonIntent.pay,
      shape: KlarnaButtonShape.pill,
      style: KlarnaButtonStyle.outlined,
      theme: KlarnaTheme.dark,
    );

    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
