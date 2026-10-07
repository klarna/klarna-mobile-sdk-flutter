/// Klarna Network Payment (KEC) integration for Flutter, reached through an
/// initialized [Klarna] — `klarna.payment.initiate(...)` (no public constructor).
library;

import 'package:flutter/foundation.dart' show internal, visibleForTesting;
import 'package:flutter/services.dart';
import 'package:klarna_network_core/klarna_network_core.dart';

import 'src/klarna_payment_error.dart';
import 'src/messages.g.dart';

export 'package:klarna_network_core/klarna_network_core.dart'
    show
        KlarnaButtonShape,
        KlarnaButtonState,
        KlarnaButtonStyle,
        KlarnaSDKError,
        KlarnaTheme;
export 'src/klarna_payment_button.dart';
export 'src/klarna_payment_button_configuration.dart'
    show KlarnaPaymentButtonConfiguration, KlarnaPaymentButtonIntent;

// Public `Klarna*` types alias the Pigeon `Kn*` transport types (the `Kn`
// prefix avoids colliding with the native SDK's `Klarna*` types).
typedef KlarnaPaymentRequest = KnPaymentRequest;
typedef KlarnaPaymentRequestState = KnPaymentRequestState;
typedef KlarnaPaymentRequestStateReason = KnPaymentRequestStateReason;
typedef KlarnaCollectCustomerProfileType = KnCollectCustomerProfileType;
typedef KlarnaRequestCustomerTokenScope = KnRequestCustomerTokenScope;
typedef KlarnaShippingConfigMode = KnShippingConfigMode;
typedef KlarnaShippingType = KnShippingType;
typedef KlarnaShippingTypeAttribute = KnShippingTypeAttribute;
typedef KlarnaInterval = KnInterval;
typedef KlarnaFreeTrial = KnFreeTrial;
typedef KlarnaPaymentRequestData = KnPaymentRequestData;
typedef KlarnaPaymentRequestStateContext = KnPaymentRequestStateContext;
typedef KlarnaRequestCustomerToken = KnRequestCustomerToken;
typedef KlarnaShippingConfig = KnShippingConfig;
typedef KlarnaSupplementaryPurchaseData = KnSupplementaryPurchaseData;
typedef KlarnaPartnerCustomer = KnPartnerCustomer;
typedef KlarnaAddress = KnAddress;
typedef KlarnaLineItem = KnLineItem;
typedef KlarnaShipping = KnShipping;
typedef KlarnaShippingRecipient = KnShippingRecipient;
typedef KlarnaShippingOption = KnShippingOption;
typedef KlarnaOndemandService = KnOndemandService;
typedef KlarnaSubscription = KnSubscription;
typedef KlarnaBillingPlan = KnBillingPlan;
typedef KlarnaCustomer = KnCustomer;
typedef KlarnaCustomerProfile = KnCustomerProfile;
typedef KlarnaPaymentPresentationContent = KnPresentationContent;
typedef KlarnaPaymentPresentationData = KnPresentationData;
typedef KlarnaPaymentPresentationPaymentOption = KnPresentationPaymentOption;
typedef KlarnaPaymentPresentationText = KnPresentationText;
typedef KlarnaPaymentPresentationTextPart = KnPresentationTextPart;
typedef KlarnaPaymentPresentationPaymentButton = KnPresentationPaymentButton;
typedef KlarnaPaymentPresentationIcon = KnPresentationIcon;
typedef KlarnaPaymentPresentationIntent = KnPresentationIntent;
typedef KlarnaPaymentPresentationInstruction = KnPresentationInstruction;
typedef KlarnaPaymentPresentationPaymentStatus = KnPresentationPaymentStatus;
typedef KlarnaPaymentPresentationImageAlignment = KnPresentationImageAlignment;
typedef KlarnaPaymentPresentationTextPartStyle = KnPresentationTextPartStyle;
typedef KlarnaPaymentPresentationTextPartLinkContext
    = KnPresentationTextPartLinkContext;

/// Caches one [KlarnaPayment] per [Klarna] so repeated `klarna.payment` returns the
/// same object. `Expando` is weak, so the payment is collected with its `Klarna`.
final Expando<KlarnaPayment> _paymentCache = Expando<KlarnaPayment>();

/// Adds `payment` to an initialized [Klarna], so the payment API is only
/// reachable from a real instance — `klarna.payment.initiate(...)`.
extension KlarnaNetworkPaymentX on Klarna {
  /// The payment feature for this instance.
  KlarnaPayment get payment =>
      _paymentCache[this] ??= KlarnaPayment._(_id(this));
}

// instanceId is @internal; this sibling package is a sanctioned consumer.
// ignore: invalid_use_of_internal_member
String _id(Klarna klarna) => klarna.instanceId;

/// Manages the Klarna Network Payment lifecycle for a single network instance.
/// Obtain it via `klarna.payment`; it is not constructible directly.
class KlarnaPayment {
  KlarnaPayment._(this.instanceId) : _api = KnPaymentHostApi();

  /// Test-only constructor injecting an explicit id. Not part of the public
  /// contract.
  @visibleForTesting
  factory KlarnaPayment.test({required String instanceId}) =>
      KlarnaPayment._(instanceId);

  final KnPaymentHostApi _api;

  /// Identifies the bound network instance for internal routing.
  @internal
  final String instanceId;

  /// Access to payment presentation content.
  late final KlarnaPaymentPresentation presentation =
      KlarnaPaymentPresentation._(_api, instanceId);

  /// Initiates a payment from a request id or [KlarnaPaymentRequestData].
  Future<KlarnaPaymentRequest> initiate(Object paymentRequestIdOrData) {
    if (paymentRequestIdOrData is String) {
      return _mapPaymentException(
          _api.initiateWithId(instanceId, paymentRequestIdOrData));
    }
    if (paymentRequestIdOrData is KlarnaPaymentRequestData) {
      return _mapPaymentException(
          _api.initiateWithData(instanceId, paymentRequestIdOrData));
    }
    throw ArgumentError(
      'initiate expects a String paymentRequestId or KlarnaPaymentRequestData, '
      'got ${paymentRequestIdOrData.runtimeType}',
    );
  }

  /// Fetches the payment request identified by [paymentRequestId].
  Future<KlarnaPaymentRequest> fetch(String paymentRequestId) =>
      _mapPaymentException(_api.fetch(instanceId, paymentRequestId));

  /// Cancels the payment request identified by [paymentRequestId].
  Future<KlarnaPaymentRequest> cancel(String paymentRequestId) =>
      _mapPaymentException(_api.cancel(instanceId, paymentRequestId));

  Future<T> _mapPaymentException<T>(Future<T> future) async {
    try {
      return await future;
    } on PlatformException catch (error) {
      throw klarnaSDKErrorFromPlatformException(error);
    }
  }
}

/// Fetches and handles Klarna payment presentation content.
class KlarnaPaymentPresentation {
  KlarnaPaymentPresentation._(this._api, this._instanceId);

  final KnPaymentHostApi _api;
  final String _instanceId;

  /// Fetches presentation content for [data].
  Future<KlarnaPaymentPresentationContent> fetch(
          KlarnaPaymentPresentationData data) =>
      _mapPaymentException(_api.presentationFetch(_instanceId, data));

  /// Handles a presentation link [url] and returns updated content.
  Future<KlarnaPaymentPresentationContent> handleLink(String url) =>
      _mapPaymentException(_api.presentationHandleLink(_instanceId, url));

  Future<T> _mapPaymentException<T>(Future<T> future) async {
    try {
      return await future;
    } on PlatformException catch (error) {
      throw klarnaSDKErrorFromPlatformException(error);
    }
  }
}
