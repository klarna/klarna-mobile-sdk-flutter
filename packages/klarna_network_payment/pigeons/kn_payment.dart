// Pigeon schema for Klarna Network Payment (Flutter<->native contract).
// Regenerate: dart run pigeon --input pigeons/kn_payment.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut:
        'ios/klarna_network_payment/Sources/klarna_network_payment/Messages.g.swift',
    kotlinOut:
        'android/src/main/kotlin/com/klarna/mobile/sdk/klarna_network_payment/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.klarna.mobile.sdk.klarna_network_payment',
    ),
    dartPackageName: 'klarna_network_payment',
  ),
)
enum KnPaymentRequestState {
  submitted,
  inProgress,
  completed,
  expired,
  canceled,
  declined,
}

enum KnPaymentRequestStateReason {
  partnerCanceled,
  paymentRequestSubmitted,
  purchaseFlowAborted,
  technicalError,
  paymentDeclined,
}

enum KnCollectCustomerProfileType {
  billingAddress,
  country,
  dateOfBirth,
  email,
  locale,
  name,
  nationalIdentification,
  phone,
}

enum KnRequestCustomerTokenScope {
  customerLogin,
  paymentCustomerNotPresent,
  paymentCustomerPresent,
}

enum KnShippingConfigMode { editable }

enum KnShippingType {
  digitalDownload,
  digitalEmail,
  digitalOther,
  physicalOther,
  pickupBox,
  pickupPoint,
  pickupStore,
  pickupWarehouse,
  toCurb,
  toDoor,
  toMailbox,
}

enum KnShippingTypeAttribute {
  contactlessDelivery,
  express,
  identificationRequired,
  leaveAtCurb,
  leaveAtDoor,
  leaveWithNeighbour,
  signatureRequired,
  tracked,
  untracked,
}

enum KnInterval { day, week, month, year }

enum KnFreeTrial { active, inactive }

enum KnPresentationIntent { pay, subscribe, addToWallet }

enum KnPresentationInstruction { showKlarna, preselectKlarna, showOnlyKlarna }

enum KnPresentationPaymentStatus {
  pendingPartnerAuthorization,
  requiresCustomerAction,
}

enum KnPresentationImageAlignment { left, right }

enum KnPresentationTextPartStyle { bold, italic, underline }

enum KnPresentationTextPartLinkContext { auth, info }

class KnPaymentRequestData {
  KnPaymentRequestData({
    required this.currency,
    required this.amount,
    this.paymentOptionId,
    this.paymentRequestReference,
    this.requestCustomerToken,
    this.shippingConfig,
    this.collectCustomerProfile,
    this.supplementaryPurchaseData,
  });

  String currency;
  int amount;
  String? paymentOptionId;
  String? paymentRequestReference;
  KnRequestCustomerToken? requestCustomerToken;
  KnShippingConfig? shippingConfig;
  List<KnCollectCustomerProfileType?>? collectCustomerProfile;
  KnSupplementaryPurchaseData? supplementaryPurchaseData;
}

class KnPaymentRequest {
  KnPaymentRequest({
    required this.paymentRequestId,
    required this.state,
    this.previousState,
    this.stateReason,
    this.paymentRequestReference,
    this.stateContext,
  });

  String paymentRequestId;
  KnPaymentRequestState state;
  KnPaymentRequestState? previousState;
  KnPaymentRequestStateReason? stateReason;
  String? paymentRequestReference;
  KnPaymentRequestStateContext? stateContext;
}

class KnRequestCustomerToken {
  KnRequestCustomerToken({required this.scopes, this.customerTokenReference});

  List<KnRequestCustomerTokenScope?> scopes;
  String? customerTokenReference;
}

class KnShippingConfig {
  KnShippingConfig({required this.mode, this.supportedCountries});

  KnShippingConfigMode mode;
  List<String>? supportedCountries;
}

class KnSupplementaryPurchaseData {
  KnSupplementaryPurchaseData({
    this.customer,
    this.lineItems,
    this.purchaseReference,
    this.shipping,
    this.ondemandService,
    this.subscriptions,
  });

  KnPartnerCustomer? customer;
  List<KnLineItem>? lineItems;
  String? purchaseReference;
  List<KnShipping>? shipping;
  KnOndemandService? ondemandService;
  List<KnSubscription>? subscriptions;
}

class KnPartnerCustomer {
  KnPartnerCustomer({
    this.address,
    this.email,
    this.familyName,
    this.givenName,
    this.phone,
  });

  KnAddress? address;
  String? email;
  String? familyName;
  String? givenName;
  String? phone;
}

class KnAddress {
  KnAddress({
    this.streetAddress,
    this.streetAddress2,
    this.city,
    this.region,
    this.postalCode,
    this.country,
  });

  String? streetAddress;
  String? streetAddress2;
  String? city;
  String? region;
  String? postalCode;
  String? country;
}

class KnLineItem {
  KnLineItem({
    required this.name,
    required this.quantity,
    required this.totalAmount,
    this.currency,
    this.imageUrl,
    this.productIdentifier,
    this.productUrl,
    this.lineItemReference,
    this.shippingReference,
    this.subscriptionReference,
    this.totalTaxAmount,
    this.unitPrice,
  });

  String name;
  int quantity;
  int totalAmount;
  String? currency;
  String? imageUrl;
  String? productIdentifier;
  String? productUrl;
  String? lineItemReference;
  String? shippingReference;
  String? subscriptionReference;
  int? totalTaxAmount;
  int? unitPrice;
}

class KnShipping {
  KnShipping({
    this.address,
    this.recipient,
    this.shippingOption,
    this.shippingReference,
  });

  KnAddress? address;
  KnShippingRecipient? recipient;
  KnShippingOption? shippingOption;
  String? shippingReference;
}

class KnShippingRecipient {
  KnShippingRecipient({
    required this.familyName,
    required this.givenName,
    this.attention,
    this.email,
    this.phone,
  });

  String familyName;
  String givenName;
  String? attention;
  String? email;
  String? phone;
}

class KnShippingOption {
  KnShippingOption({
    required this.shippingType,
    this.shippingCarrier,
    this.shippingTypeAttributes,
  });

  KnShippingType shippingType;
  String? shippingCarrier;
  List<KnShippingTypeAttribute?>? shippingTypeAttributes;
}

class KnOndemandService {
  KnOndemandService({
    this.currency,
    this.averageAmount,
    this.minimumAmount,
    this.maximumAmount,
    this.purchaseInterval,
    this.purchaseIntervalFrequency,
  });

  String? currency;
  int? averageAmount;
  int? minimumAmount;
  int? maximumAmount;
  KnInterval? purchaseInterval;
  int? purchaseIntervalFrequency;
}

class KnSubscription {
  KnSubscription({
    required this.subscriptionReference,
    this.name,
    this.freeTrial,
    this.billingPlans,
  });

  String subscriptionReference;
  String? name;
  KnFreeTrial? freeTrial;
  List<KnBillingPlan>? billingPlans;
}

class KnBillingPlan {
  KnBillingPlan({
    required this.billingAmount,
    required this.from,
    required this.interval,
    required this.intervalFrequency,
    this.currency,
  });

  int billingAmount;
  String from;
  KnInterval interval;
  int intervalFrequency;
  String? currency;
}

class KnPaymentRequestStateContext {
  KnPaymentRequestStateContext({
    this.klarnaNetworkSessionToken,
    this.klarnaCustomer,
    this.shipping,
  });

  String? klarnaNetworkSessionToken;
  KnCustomer? klarnaCustomer;
  KnShipping? shipping;
}

class KnCustomer {
  KnCustomer({
    this.customerToken,
    this.customerTokenReference,
    this.customerProfile,
  });

  String? customerToken;
  String? customerTokenReference;
  KnCustomerProfile? customerProfile;
}

class KnCustomerProfile {
  KnCustomerProfile({
    this.address,
    this.customerId,
    this.country,
    this.email,
    this.emailVerified,
    this.familyName,
    this.givenName,
    this.locale,
    this.phone,
    this.phoneVerified,
  });

  KnAddress? address;
  String? customerId;
  String? country;
  String? email;
  bool? emailVerified;
  String? familyName;
  String? givenName;
  String? locale;
  String? phone;
  bool? phoneVerified;
}

class KnPresentationData {
  KnPresentationData({
    required this.currency,
    required this.amount,
    this.intent,
    this.paymentProgramEnablementCodes,
    this.subscriptionBillingInterval,
    this.subscriptionBillingIntervalFrequency,
  });

  String currency;
  int amount;
  KnPresentationIntent? intent;
  List<String>? paymentProgramEnablementCodes;
  KnInterval? subscriptionBillingInterval;
  int? subscriptionBillingIntervalFrequency;
}

class KnPresentationContent {
  KnPresentationContent({
    required this.instruction,
    this.paymentStatus,
    this.paymentOption,
    this.savedPaymentOption,
  });

  KnPresentationInstruction instruction;
  KnPresentationPaymentStatus? paymentStatus;
  KnPresentationPaymentOption? paymentOption;
  KnPresentationPaymentOption? savedPaymentOption;
}

class KnPresentationPaymentOption {
  KnPresentationPaymentOption({
    required this.paymentOptionId,
    this.header,
    this.badge,
    this.subheader,
    this.message,
    this.terms,
    this.paymentButton,
    this.icon,
  });

  String paymentOptionId;
  KnPresentationText? header;
  KnPresentationText? badge;
  KnPresentationText? subheader;
  KnPresentationText? message;
  KnPresentationText? terms;
  KnPresentationPaymentButton? paymentButton;
  KnPresentationIcon? icon;
}

class KnPresentationText {
  KnPresentationText({required this.type, this.text, this.parts});

  String type;
  String? text;
  List<KnPresentationTextPart>? parts;
}

class KnPresentationTextPart {
  KnPresentationTextPart({
    required this.type,
    required this.text,
    this.url,
    this.context,
    this.styles,
  });

  String type;
  String text;
  String? url;
  KnPresentationTextPartLinkContext? context;
  List<KnPresentationTextPartStyle?>? styles;
}

class KnPresentationPaymentButton {
  KnPresentationPaymentButton({
    required this.text,
    this.imageUrl,
    this.imageAlignment,
  });

  String text;
  String? imageUrl;
  KnPresentationImageAlignment? imageAlignment;
}

class KnPresentationIcon {
  KnPresentationIcon({
    this.alt,
    this.badgeImageUrl,
    this.rectangleImageUrl,
    this.squareImageUrl,
  });

  String? alt;
  String? badgeImageUrl;
  String? rectangleImageUrl;
  String? squareImageUrl;
}

@HostApi()
abstract class KnPaymentHostApi {
  @async
  KnPaymentRequest initiateWithId(String instanceId, String paymentRequestId);

  @async
  KnPaymentRequest initiateWithData(
    String instanceId,
    KnPaymentRequestData data,
  );

  @async
  KnPaymentRequest fetch(String instanceId, String paymentRequestId);

  @async
  KnPaymentRequest cancel(String instanceId, String paymentRequestId);

  @async
  KnPresentationContent presentationFetch(
    String instanceId,
    KnPresentationData data,
  );

  @async
  KnPresentationContent presentationHandleLink(String instanceId, String url);
}

@FlutterApi()
abstract class KnPaymentFlutterApi {
  void onButtonPressed(int viewId);
}
