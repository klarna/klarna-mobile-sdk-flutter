import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_core/src/messages.g.dart' as core_messages;
import 'package:klarna_network_messaging/klarna_network_messaging.dart';
import 'package:klarna_network_messaging/src/klarna_messaging_events.dart';
import 'package:klarna_network_messaging/src/klarna_messaging_height.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('nextHeightOnResize', () {
    test('returns the new height when it changed', () {
      expect(
        nextHeightOnResize(rawHeight: 120, prevHeight: 0, hasError: false),
        120,
      );
    });

    test('skips updates while in an error state', () {
      expect(
        nextHeightOnResize(rawHeight: 120, prevHeight: 0, hasError: true),
        isNull,
      );
    });

    test('skips negative or non-finite heights', () {
      expect(
        nextHeightOnResize(rawHeight: -1, prevHeight: 0, hasError: false),
        isNull,
      );
      expect(
        nextHeightOnResize(
            rawHeight: double.nan, prevHeight: 0, hasError: false),
        isNull,
      );
      expect(
        nextHeightOnResize(
            rawHeight: double.infinity, prevHeight: 0, hasError: false),
        isNull,
      );
    });

    test('skips an unchanged height after the first resize', () {
      expect(
        nextHeightOnResize(rawHeight: 80, prevHeight: 80, hasError: false),
        isNull,
      );
    });

    test('accepts height 0 on the first resize so the view can collapse', () {
      expect(
        nextHeightOnResize(
          rawHeight: 0,
          prevHeight: 0,
          hasError: false,
          isFirstResize: true,
        ),
        0,
      );
    });

    test('skips a repeated 0 height after the first resize', () {
      expect(
        nextHeightOnResize(
          rawHeight: 0,
          prevHeight: 0,
          hasError: false,
          isFirstResize: false,
        ),
        isNull,
      );
    });
  });

  group('KlarnaMessagingEventDispatcher', () {
    final dispatcher = KlarnaMessagingEventDispatcher.instance;

    test('routes onResized to the registered view id', () {
      final heights = <double>[];
      dispatcher.registerResized(10, heights.add);
      addTearDown(() => dispatcher.unregister(10));

      dispatcher.onResized(10, 42);

      expect(heights, [42]);
    });

    test('routes each event only to its own view id', () {
      final a = <double>[];
      final b = <double>[];
      dispatcher.registerResized(12, a.add);
      dispatcher.registerResized(13, b.add);
      addTearDown(() {
        dispatcher.unregister(12);
        dispatcher.unregister(13);
      });

      dispatcher.onResized(13, 5);
      dispatcher.onResized(12, 9);

      expect(a, [9]);
      expect(b, [5]);
    });

    test('does nothing for an unregistered view id', () {
      expect(() => dispatcher.onResized(999, 1), returnsNormally);
    });

    test('unregister stops further callbacks', () {
      final heights = <double>[];
      dispatcher.registerResized(14, heights.add);
      dispatcher.onResized(14, 1);
      dispatcher.unregister(14);
      dispatcher.onResized(14, 2);

      expect(heights, [1]);
    });
  });

  group('KlarnaMessagingPlacementConfiguration', () {
    test('value equality covers all fields', () {
      const a = KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
        amount: 1000,
        currency: 'EUR',
        theme: KlarnaTheme.dark,
      );
      const b = KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
        amount: 1000,
        currency: 'EUR',
        theme: KlarnaTheme.dark,
      );
      const c = KlarnaMessagingPlacementConfiguration.creditPromotionBadge(
        amount: 1000,
        currency: 'EUR',
        theme: KlarnaTheme.dark,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('theme defaults to null', () {
      const config =
          KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
        amount: 1000,
        currency: 'EUR',
      );

      expect(config.theme, isNull);
    });

    test('differs when any field differs', () {
      const base =
          KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
        amount: 1000,
        currency: 'EUR',
      );

      expect(
        base,
        isNot(
            const KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
                amount: 1001, currency: 'EUR')),
      );
      expect(
        base,
        isNot(
            const KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
                amount: 1000, currency: 'USD')),
      );
      expect(
        base,
        isNot(
            const KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
          amount: 1000,
          currency: 'EUR',
          theme: KlarnaTheme.dark,
        )),
      );
      expect(base, isNot(Object()));
    });
  });

  group('KlarnaMessagingPlacementView', () {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

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
        'msg-1',
      );
    });

    tearDownAll(() {
      messenger.setMockMessageHandler(
        'dev.flutter.pigeon.klarna_network_core.KnCoreHostApi.initialize',
        null,
      );
    });

    const configuration =
        KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
      amount: 1000,
      currency: 'EUR',
    );

    Widget subject() => Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: KlarnaMessagingPlacementView(
              instance: klarna,
              configuration: configuration,
            ),
          ),
        );

    double laidOutHeight(WidgetTester tester) =>
        tester.getSize(find.byType(KlarnaMessagingPlacementView)).height;

    testWidgets('starts at the fallback height before the first resize',
        (tester) async {
      await tester.pumpWidget(subject());

      expect(laidOutHeight(tester), 60);
    });

    /// Captures the view ids the widget hands to the native layer via the
    /// platform-views channel, so tests can drive native resize events.
    List<int> captureViewIds() {
      final viewIds = <int>[];
      messenger.setMockMethodCallHandler(SystemChannels.platform_views,
          (call) async {
        if (call.method == 'create') {
          final args = call.arguments as Map<dynamic, dynamic>;
          final params = args['params'];
          if (params is Uint8List) {
            final decoded = const StandardMessageCodec()
                .decodeMessage(ByteData.sublistView(params));
            if (decoded is Map && decoded['viewId'] is int) {
              viewIds.add(decoded['viewId'] as int);
            }
          }
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(
          SystemChannels.platform_views, null));
      return viewIds;
    }

    testWidgets('applies native resize events to its height', (tester) async {
      final viewIds = captureViewIds();
      await tester.pumpWidget(subject());
      expect(viewIds, isNotEmpty);

      KlarnaMessagingEventDispatcher.instance.onResized(viewIds.last, 120);
      await tester.pump();

      expect(laidOutHeight(tester), 120);
    });

    testWidgets('collapses to zero when the first resize reports zero',
        (tester) async {
      final viewIds = captureViewIds();
      await tester.pumpWidget(subject());
      expect(viewIds, isNotEmpty);

      KlarnaMessagingEventDispatcher.instance.onResized(viewIds.last, 0);
      await tester.pump();

      expect(laidOutHeight(tester), 0);
    });

    testWidgets('resets to the fallback height when the configuration changes',
        (tester) async {
      final viewIds = captureViewIds();
      await tester.pumpWidget(subject());
      KlarnaMessagingEventDispatcher.instance.onResized(viewIds.last, 120);
      await tester.pump();
      expect(laidOutHeight(tester), 120);

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: KlarnaMessagingPlacementView(
            instance: klarna,
            configuration: const KlarnaMessagingPlacementConfiguration
                .creditPromotionBadge(amount: 1000, currency: 'EUR'),
          ),
        ),
      ));

      expect(laidOutHeight(tester), 60);
    });
  });
}
