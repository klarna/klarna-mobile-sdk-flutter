import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_mobile_sdk_flutter_example/klarnanetworkpayment/payment_request_display.dart';
import 'package:klarna_network_payment/klarna_network_payment.dart';

void main() {
  group('paymentRequestToDisplayString', () {
    test('renders only id and state for a minimal request', () {
      final text = paymentRequestToDisplayString(
        KlarnaPaymentRequest(
          paymentRequestId: 'pr-1',
          state: KlarnaPaymentRequestState.submitted,
        ),
      );

      expect(text, 'paymentRequestId: pr-1\nstate: submitted');
    });

    test('omits optional top-level fields when absent', () {
      final text = paymentRequestToDisplayString(
        KlarnaPaymentRequest(
          paymentRequestId: 'pr-1',
          state: KlarnaPaymentRequestState.submitted,
        ),
      );

      expect(text, isNot(contains('previousState')));
      expect(text, isNot(contains('stateReason')));
      expect(text, isNot(contains('paymentRequestReference')));
      expect(text, isNot(contains('stateContext')));
    });

    test('renders optional top-level fields when present', () {
      final text = paymentRequestToDisplayString(
        KlarnaPaymentRequest(
          paymentRequestId: 'pr-1',
          state: KlarnaPaymentRequestState.completed,
          previousState: KlarnaPaymentRequestState.inProgress,
          stateReason: KlarnaPaymentRequestStateReason.paymentRequestSubmitted,
          paymentRequestReference: 'ref-9',
        ),
      );

      expect(text, contains('previousState: inProgress'));
      expect(text, contains('stateReason: paymentRequestSubmitted'));
      expect(text, contains('paymentRequestReference: ref-9'));
    });

    test('renders nested customer and shipping from the state context', () {
      final text = paymentRequestToDisplayString(
        KlarnaPaymentRequest(
          paymentRequestId: 'pr-1',
          state: KlarnaPaymentRequestState.completed,
          stateContext: KlarnaPaymentRequestStateContext(
            klarnaNetworkSessionToken: 'session-abc',
            klarnaCustomer: KlarnaCustomer(
              customerToken: 'cust-tok',
              customerProfile: KlarnaCustomerProfile(
                email: 'ada@example.com',
                givenName: 'Ada',
                familyName: 'Lovelace',
              ),
            ),
            shipping: KlarnaShipping(
              recipient: KlarnaShippingRecipient(
                givenName: 'Ada',
                familyName: 'Lovelace',
              ),
              shippingOption: KlarnaShippingOption(
                shippingType: KlarnaShippingType.toDoor,
              ),
              address: KlarnaAddress(country: 'GB'),
            ),
          ),
        ),
      );

      expect(text, contains('stateContext:'));
      expect(text, contains('sessionToken: session-abc'));
      expect(text, contains('token: cust-tok'));
      expect(text, contains('email: ada@example.com'));
      expect(text, contains('name: Ada Lovelace'));
      expect(text, contains('recipient: Ada Lovelace'));
      expect(text, contains('shippingType: toDoor'));
      expect(text, contains('country: GB'));
    });

    test('has no trailing newline', () {
      final text = paymentRequestToDisplayString(
        KlarnaPaymentRequest(
          paymentRequestId: 'pr-1',
          state: KlarnaPaymentRequestState.submitted,
        ),
      );

      expect(text, isNot(endsWith('\n')));
    });
  });
}
