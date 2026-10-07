import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_network_core/src/latest_platform_view_props_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LatestPlatformViewPropsDelivery', () {
    LatestPlatformViewPropsDelivery delivery() =>
        LatestPlatformViewPropsDelivery(
          onError: (error, stackTrace) {
            fail('Unexpected delivery error: $error');
          },
        );

    test('coalesces pre-creation updates to the latest props', () {
      final sent = <Map<String, Object?>>[];
      final subject = delivery()
        ..update(const {'amount': '200'})
        ..update(const {'amount': '300'})
        ..attach((props) async => sent.add(props));

      expect(sent, [
        const {'amount': '300'},
      ]);
      subject.dispose();
    });

    test('delivers latest props when they return to the initial values', () {
      final sent = <Map<String, Object?>>[];
      final subject = delivery()
        ..update(const {'amount': '200'})
        ..update(const {'amount': '100'})
        ..attach((props) async => sent.add(props));

      expect(sent, [
        const {'amount': '100'},
      ]);
      subject.dispose();
    });

    test('does not duplicate creation props without an update', () {
      final sent = <Map<String, Object?>>[];
      final subject = delivery()..attach((props) async => sent.add(props));

      expect(sent, isEmpty);
      subject.dispose();
    });

    test('sends updates immediately after creation', () {
      final sent = <Map<String, Object?>>[];
      final subject = delivery()
        ..attach((props) async => sent.add(props))
        ..update(const {'amount': '200'});

      expect(sent, [
        const {'amount': '200'},
      ]);
      subject.dispose();
    });

    test('drops pending updates and ignores attachment after disposal', () {
      final sent = <Map<String, Object?>>[];
      delivery()
        ..update(const {'amount': '200'})
        ..dispose()
        ..attach((props) async => sent.add(props))
        ..update(const {'amount': '300'});

      expect(sent, isEmpty);
    });
  });
}
