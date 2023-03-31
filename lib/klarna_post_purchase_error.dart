import 'package:flutter_klarna_inapp_sdk/klarna_mobile_sdk_error.dart';

class KlarnaPostPurchaseError extends KlarnaMobileSDKError {
  KlarnaPostPurchaseError(
      String name, String message, String? status, bool isFatal)
      : super(name, message, status, isFatal);
}
