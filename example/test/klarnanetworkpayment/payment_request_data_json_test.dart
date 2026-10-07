import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_mobile_sdk_flutter_example/klarnanetworkpayment/payment_request_data_json.dart';
import 'package:klarna_network_payment/klarna_network_payment.dart';

void main() {
  group('paymentRequestDataFromJson', () {
    test('decodes the minimal required fields', () {
      final data =
          paymentRequestDataFromJson({'amount': 1000, 'currency': 'EUR'});

      expect(data.amount, 1000);
      expect(data.currency, 'EUR');
      expect(data.paymentOptionId, isNull);
      expect(data.requestCustomerToken, isNull);
      expect(data.shippingConfig, isNull);
      expect(data.collectCustomerProfile, isNull);
      expect(data.supplementaryPurchaseData, isNull);
    });

    test('throws FormatException on a missing required field', () {
      expect(
        () => paymentRequestDataFromJson({'currency': 'EUR'}),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', contains('amount'))),
      );
    });

    test('throws FormatException when amount is not an int', () {
      expect(
        () => paymentRequestDataFromJson({'amount': '1000', 'currency': 'EUR'}),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', contains('amount'))),
      );
    });

    test('decodes top-level optional scalars', () {
      final data = paymentRequestDataFromJson({
        'amount': 500,
        'currency': 'USD',
        'paymentOptionId': 'opt-1',
        'paymentRequestReference': 'ref-1',
      });

      expect(data.paymentOptionId, 'opt-1');
      expect(data.paymentRequestReference, 'ref-1');
    });

    group('requestCustomerToken', () {
      test('decodes scopes as an enum list', () {
        final data = paymentRequestDataFromJson({
          'amount': 1,
          'currency': 'EUR',
          'requestCustomerToken': {
            'scopes': ['customer:login', 'payment:customer_present'],
            'customerTokenReference': 'tok-ref',
          },
        });

        final token = data.requestCustomerToken!;
        expect(token.scopes, [
          KlarnaRequestCustomerTokenScope.customerLogin,
          KlarnaRequestCustomerTokenScope.paymentCustomerPresent,
        ]);
        expect(token.customerTokenReference, 'tok-ref');
      });

      test('defaults scopes to empty when absent', () {
        final data = paymentRequestDataFromJson({
          'amount': 1,
          'currency': 'EUR',
          'requestCustomerToken': {'customerTokenReference': 'tok-ref'},
        });

        expect(data.requestCustomerToken!.scopes, isEmpty);
      });

      test('throws on an unknown scope wire value', () {
        expect(
          () => paymentRequestDataFromJson({
            'amount': 1,
            'currency': 'EUR',
            'requestCustomerToken': {
              'scopes': ['customer:bogus'],
            },
          }),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', contains('customer:bogus'))
              .having((e) => e.message, 'message', contains('scopes'))),
        );
      });
    });

    group('shippingConfig', () {
      test('decodes mode and supportedCountries', () {
        final data = paymentRequestDataFromJson({
          'amount': 1,
          'currency': 'EUR',
          'shippingConfig': {
            'mode': 'EDITABLE',
            'supportedCountries': ['SE', 'DE'],
          },
        });

        final config = data.shippingConfig!;
        expect(config.mode, KlarnaShippingConfigMode.editable);
        expect(config.supportedCountries, ['SE', 'DE']);
      });

      test('throws on an unknown mode', () {
        expect(
          () => paymentRequestDataFromJson({
            'amount': 1,
            'currency': 'EUR',
            'shippingConfig': {'mode': 'READONLY'},
          }),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', contains('mode'))),
        );
      });
    });

    test('decodes collectCustomerProfile enum list', () {
      final data = paymentRequestDataFromJson({
        'amount': 1,
        'currency': 'EUR',
        'collectCustomerProfile': ['profile:email', 'profile:name'],
      });

      expect(data.collectCustomerProfile, [
        KlarnaCollectCustomerProfileType.email,
        KlarnaCollectCustomerProfileType.name,
      ]);
    });

    group('supplementaryPurchaseData', () {
      test('decodes nested customer, line items, and shipping', () {
        final data = paymentRequestDataFromJson({
          'amount': 1,
          'currency': 'EUR',
          'supplementaryPurchaseData': {
            'purchaseReference': 'purchase-1',
            'customer': {
              'givenName': 'Ada',
              'familyName': 'Lovelace',
              'email': 'ada@example.com',
              'address': {'country': 'GB', 'city': 'London'},
            },
            'lineItems': [
              {'name': 'Widget', 'quantity': 2, 'totalAmount': 400},
            ],
            'shipping': [
              {
                'recipient': {'givenName': 'Ada', 'familyName': 'Lovelace'},
                'shippingOption': {
                  'shippingType': 'TO_DOOR',
                  'shippingTypeAttributes': ['EXPRESS', 'TRACKED'],
                },
              },
            ],
          },
        });

        final supp = data.supplementaryPurchaseData!;
        expect(supp.purchaseReference, 'purchase-1');
        expect(supp.customer!.givenName, 'Ada');
        expect(supp.customer!.address!.country, 'GB');

        final item = supp.lineItems!.single;
        expect(item.name, 'Widget');
        expect(item.quantity, 2);
        expect(item.totalAmount, 400);

        final shippingOption = supp.shipping!.single.shippingOption!;
        expect(shippingOption.shippingType, KlarnaShippingType.toDoor);
        expect(shippingOption.shippingTypeAttributes, [
          KlarnaShippingTypeAttribute.express,
          KlarnaShippingTypeAttribute.tracked,
        ]);
      });

      test('decodes subscriptions with a billing plan and free trial', () {
        final data = paymentRequestDataFromJson({
          'amount': 1,
          'currency': 'EUR',
          'supplementaryPurchaseData': {
            'subscriptions': [
              {
                'subscriptionReference': 'sub-1',
                'name': 'Monthly',
                'freeTrial': 'ACTIVE',
                'billingPlans': [
                  {
                    'billingAmount': 999,
                    'from': '2026-01-01',
                    'interval': 'MONTH',
                    'intervalFrequency': 1,
                    'currency': 'EUR',
                  },
                ],
              },
            ],
            'ondemandService': {
              'currency': 'EUR',
              'purchaseInterval': 'WEEK',
              'purchaseIntervalFrequency': 2,
            },
          },
        });

        final sub = data.supplementaryPurchaseData!.subscriptions!.single;
        expect(sub.subscriptionReference, 'sub-1');
        expect(sub.freeTrial, KlarnaFreeTrial.active);

        final plan = sub.billingPlans!.single;
        expect(plan.billingAmount, 999);
        expect(plan.from, '2026-01-01');
        expect(plan.interval, KlarnaInterval.month);
        expect(plan.intervalFrequency, 1);

        final onDemand = data.supplementaryPurchaseData!.ondemandService!;
        expect(onDemand.purchaseInterval, KlarnaInterval.week);
        expect(onDemand.purchaseIntervalFrequency, 2);
      });

      test('throws when a nested required field is missing', () {
        expect(
          () => paymentRequestDataFromJson({
            'amount': 1,
            'currency': 'EUR',
            'supplementaryPurchaseData': {
              'lineItems': [
                {'name': 'Widget', 'quantity': 2},
              ],
            },
          }),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', contains('totalAmount'))),
        );
      });
    });
  });
}
