import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_environment.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_mobile_sdk_error.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_error.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_post_purchase_render_result.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_region.dart';
import 'package:klarna_mobile_sdk_flutter/klarna_resource_endpoint.dart';

void main() {
  group('KlarnaMobileSDKError', () {
    test('stores all fields', () {
      final error = KlarnaMobileSDKError('SomeError', 'a message', '400', true);

      expect(error.name, 'SomeError');
      expect(error.message, 'a message');
      expect(error.status, '400');
      expect(error.isFatal, true);
    });

    test('allows a null status', () {
      final error = KlarnaMobileSDKError('SomeError', 'a message', null, false);

      expect(error.status, isNull);
      expect(error.isFatal, false);
    });
  });

  group('KlarnaPostPurchaseError', () {
    test('is a KlarnaMobileSDKError and forwards its fields', () {
      final error = KlarnaPostPurchaseError('PPError', 'oops', '500', true);

      expect(error, isA<KlarnaMobileSDKError>());
      expect(error.name, 'PPError');
      expect(error.message, 'oops');
      expect(error.status, '500');
      expect(error.isFatal, true);
    });
  });

  group('enum names sent over the platform channel', () {
    // The SDK maps each enum to its `.name` before sending it to the native
    // side, so these names are part of the platform contract.
    test('KlarnaEnvironment names', () {
      expect(KlarnaEnvironment.STAGING.name, 'STAGING');
      expect(KlarnaEnvironment.PLAYGROUND.name, 'PLAYGROUND');
      expect(KlarnaEnvironment.PRODUCTION.name, 'PRODUCTION');
      expect(KlarnaEnvironment.values, hasLength(3));
    });

    test('KlarnaRegion names', () {
      expect(KlarnaRegion.EU.name, 'EU');
      expect(KlarnaRegion.NA.name, 'NA');
      expect(KlarnaRegion.OC.name, 'OC');
      expect(KlarnaRegion.values, hasLength(3));
    });

    test('KlarnaResourceEndpoint names', () {
      expect(KlarnaResourceEndpoint.ALTERNATIVE_1.name, 'ALTERNATIVE_1');
      expect(KlarnaResourceEndpoint.ALTERNATIVE_2.name, 'ALTERNATIVE_2');
      expect(KlarnaResourceEndpoint.values, hasLength(2));
    });

    test('KlarnaPostPurchaseRenderResult values', () {
      expect(KlarnaPostPurchaseRenderResult.values, hasLength(2));
      expect(
        KlarnaPostPurchaseRenderResult.values,
        containsAll(<KlarnaPostPurchaseRenderResult>[
          KlarnaPostPurchaseRenderResult.stateChange,
          KlarnaPostPurchaseRenderResult.noStateChange,
        ]),
      );
    });
  });
}
