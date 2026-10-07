import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_payment/src/klarna_payment_error.dart';

void main() {
  group('klarnaSDKErrorFromPlatformException', () {
    test('maps code, message, and details', () {
      final error = klarnaSDKErrorFromPlatformException(
        PlatformException(
          code: 'PaymentError',
          message: 'something went wrong',
          details: {'k': 'v'},
        ),
      );

      expect(error.name, 'PaymentError');
      expect(error.message, 'something went wrong');
      expect(error.cause, {'k': 'v'});
    });

    test('falls back to code when message is null', () {
      final error = klarnaSDKErrorFromPlatformException(
        PlatformException(code: 'NoMessage'),
      );

      expect(error.name, 'NoMessage');
      expect(error.message, 'NoMessage');
      expect(error.cause, isNull);
    });

    test('is an Exception with a readable toString', () {
      const error = KlarnaSDKError(name: 'E', message: 'm');

      expect(error, isA<Exception>());
      expect(error.toString(), 'KlarnaSDKError(E, m)');
    });
  });
}
