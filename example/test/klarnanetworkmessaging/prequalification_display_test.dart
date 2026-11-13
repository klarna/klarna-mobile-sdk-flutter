import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_mobile_sdk_flutter_example/klarnanetworkmessaging/prequalification_display.dart';
import 'package:klarna_network_messaging/klarna_network_messaging.dart';

void main() {
  group('prequalificationResultToDisplayString', () {
    test('renders approved with the UTC expiresAt', () {
      final text = prequalificationResultToDisplayString(
        KlarnaMessagingPrequalificationApproved(
          expiresAt: DateTime.utc(2027, 1, 1, 12, 30),
        ),
      );

      expect(text, 'Approved, expires 2027-01-01T12:30:00.000Z');
    });

    test('renders approved in UTC even for a local DateTime', () {
      final instant = DateTime.utc(2027, 1, 1, 12, 30);
      final text = prequalificationResultToDisplayString(
        KlarnaMessagingPrequalificationApproved(expiresAt: instant.toLocal()),
      );

      expect(text, endsWith('2027-01-01T12:30:00.000Z'));
    });

    test('renders aborted', () {
      expect(
        prequalificationResultToDisplayString(
          const KlarnaMessagingPrequalificationAborted(),
        ),
        'Aborted',
      );
    });
  });

  group('prequalificationErrorToDisplayString', () {
    test('renders a KlarnaSDKError as name: message', () {
      final text = prequalificationErrorToDisplayString(
        KlarnaSDKError(
          name: 'INITIATE_ALREADY_IN_PROGRESS',
          message: 'A prequalification is already running.',
        ),
      );

      expect(
        text,
        'INITIATE_ALREADY_IN_PROGRESS: A prequalification is already running.',
      );
    });

    test('renders other errors with their runtime type', () {
      final text = prequalificationErrorToDisplayString(
        ArgumentError.value(0, 'data.amount', 'must be greater than 0'),
      );

      expect(text, startsWith('ArgumentError: '));
      expect(text, contains('must be greater than 0'));
    });
  });
}
