import 'package:klarna_network_payment/klarna_network_payment.dart';

/// Hand-decodes a JSON map into a [KlarnaPaymentRequestData] (Pigeon has no fromJson).
/// Enum fields take wire strings (e.g. "TO_DOOR"); throws [FormatException] on bad input.
KlarnaPaymentRequestData paymentRequestDataFromJson(Map<String, dynamic> json) {
  return KlarnaPaymentRequestData(
    amount: _requireInt(json, 'amount'),
    currency: _requireString(json, 'currency'),
    paymentOptionId: json['paymentOptionId'] as String?,
    paymentRequestReference: json['paymentRequestReference'] as String?,
    requestCustomerToken:
        _map(json['requestCustomerToken'], _requestCustomerToken),
    shippingConfig: _map(json['shippingConfig'], _shippingConfig),
    collectCustomerProfile: _enumList(
      json['collectCustomerProfile'],
      _collectCustomerProfile,
    ),
    supplementaryPurchaseData:
        _map(json['supplementaryPurchaseData'], _supplementaryPurchaseData),
  );
}

KlarnaRequestCustomerToken _requestCustomerToken(Map<String, dynamic> j) {
  return KlarnaRequestCustomerToken(
    scopes: _enumList(j['scopes'], _tokenScope) ?? const [],
    customerTokenReference: j['customerTokenReference'] as String?,
  );
}

KlarnaShippingConfig _shippingConfig(Map<String, dynamic> j) {
  return KlarnaShippingConfig(
    mode: _shippingConfigMode(_requireString(j, 'mode')),
    supportedCountries: _stringList(j['supportedCountries']),
  );
}

KlarnaSupplementaryPurchaseData _supplementaryPurchaseData(
    Map<String, dynamic> j) {
  return KlarnaSupplementaryPurchaseData(
    customer: _map(j['customer'], _partnerCustomer),
    lineItems: _objList(j['lineItems'], _lineItem),
    purchaseReference: j['purchaseReference'] as String?,
    shipping: _objList(j['shipping'], _shipping),
    ondemandService: _map(j['ondemandService'], _ondemandService),
    subscriptions: _objList(j['subscriptions'], _subscription),
  );
}

KlarnaPartnerCustomer _partnerCustomer(Map<String, dynamic> j) {
  return KlarnaPartnerCustomer(
    address: _map(j['address'], _address),
    email: j['email'] as String?,
    familyName: j['familyName'] as String?,
    givenName: j['givenName'] as String?,
    phone: j['phone'] as String?,
  );
}

KlarnaAddress _address(Map<String, dynamic> j) {
  return KlarnaAddress(
    streetAddress: j['streetAddress'] as String?,
    streetAddress2: j['streetAddress2'] as String?,
    city: j['city'] as String?,
    region: j['region'] as String?,
    postalCode: j['postalCode'] as String?,
    country: j['country'] as String?,
  );
}

KlarnaLineItem _lineItem(Map<String, dynamic> j) {
  return KlarnaLineItem(
    name: _requireString(j, 'name'),
    quantity: _requireInt(j, 'quantity'),
    totalAmount: _requireInt(j, 'totalAmount'),
    currency: j['currency'] as String?,
    imageUrl: j['imageUrl'] as String?,
    productIdentifier: j['productIdentifier'] as String?,
    productUrl: j['productUrl'] as String?,
    lineItemReference: j['lineItemReference'] as String?,
    shippingReference: j['shippingReference'] as String?,
    subscriptionReference: j['subscriptionReference'] as String?,
    totalTaxAmount: j['totalTaxAmount'] as int?,
    unitPrice: j['unitPrice'] as int?,
  );
}

KlarnaShipping _shipping(Map<String, dynamic> j) {
  return KlarnaShipping(
    address: _map(j['address'], _address),
    recipient: _map(j['recipient'], _shippingRecipient),
    shippingOption: _map(j['shippingOption'], _shippingOption),
    shippingReference: j['shippingReference'] as String?,
  );
}

KlarnaShippingRecipient _shippingRecipient(Map<String, dynamic> j) {
  return KlarnaShippingRecipient(
    familyName: _requireString(j, 'familyName'),
    givenName: _requireString(j, 'givenName'),
    attention: j['attention'] as String?,
    email: j['email'] as String?,
    phone: j['phone'] as String?,
  );
}

KlarnaShippingOption _shippingOption(Map<String, dynamic> j) {
  return KlarnaShippingOption(
    shippingType: _shippingType(_requireString(j, 'shippingType')),
    shippingCarrier: j['shippingCarrier'] as String?,
    shippingTypeAttributes:
        _enumList(j['shippingTypeAttributes'], _shippingTypeAttribute),
  );
}

KlarnaOndemandService _ondemandService(Map<String, dynamic> j) {
  return KlarnaOndemandService(
    currency: j['currency'] as String?,
    averageAmount: j['averageAmount'] as int?,
    minimumAmount: j['minimumAmount'] as int?,
    maximumAmount: j['maximumAmount'] as int?,
    purchaseInterval: j['purchaseInterval'] == null
        ? null
        : _interval(j['purchaseInterval'] as String),
    purchaseIntervalFrequency: j['purchaseIntervalFrequency'] as int?,
  );
}

KlarnaSubscription _subscription(Map<String, dynamic> j) {
  return KlarnaSubscription(
    subscriptionReference: _requireString(j, 'subscriptionReference'),
    name: j['name'] as String?,
    freeTrial:
        j['freeTrial'] == null ? null : _freeTrial(j['freeTrial'] as String),
    billingPlans: _objList(j['billingPlans'], _billingPlan),
  );
}

KlarnaBillingPlan _billingPlan(Map<String, dynamic> j) {
  return KlarnaBillingPlan(
    billingAmount: _requireInt(j, 'billingAmount'),
    from: _requireString(j, 'from'),
    interval: _interval(_requireString(j, 'interval')),
    intervalFrequency: _requireInt(j, 'intervalFrequency'),
    currency: j['currency'] as String?,
  );
}

KlarnaCollectCustomerProfileType _collectCustomerProfile(String v) => _byWire(
    v,
    {
      'profile:billing_address':
          KlarnaCollectCustomerProfileType.billingAddress,
      'profile:country': KlarnaCollectCustomerProfileType.country,
      'profile:date_of_birth': KlarnaCollectCustomerProfileType.dateOfBirth,
      'profile:email': KlarnaCollectCustomerProfileType.email,
      'profile:locale': KlarnaCollectCustomerProfileType.locale,
      'profile:name': KlarnaCollectCustomerProfileType.name,
      'profile:national_identification':
          KlarnaCollectCustomerProfileType.nationalIdentification,
      'profile:phone': KlarnaCollectCustomerProfileType.phone,
    },
    'collectCustomerProfile');

KlarnaRequestCustomerTokenScope _tokenScope(String v) => _byWire(
    v,
    {
      'customer:login': KlarnaRequestCustomerTokenScope.customerLogin,
      'payment:customer_not_present':
          KlarnaRequestCustomerTokenScope.paymentCustomerNotPresent,
      'payment:customer_present':
          KlarnaRequestCustomerTokenScope.paymentCustomerPresent,
    },
    'scopes');

KlarnaShippingConfigMode _shippingConfigMode(String v) => _byWire(
    v,
    {
      'EDITABLE': KlarnaShippingConfigMode.editable,
    },
    'mode');

KlarnaShippingType _shippingType(String v) => _byWire(
    v,
    {
      'DIGITAL_DOWNLOAD': KlarnaShippingType.digitalDownload,
      'DIGITAL_EMAIL': KlarnaShippingType.digitalEmail,
      'DIGITAL_OTHER': KlarnaShippingType.digitalOther,
      'PHYSICAL_OTHER': KlarnaShippingType.physicalOther,
      'PICKUP_BOX': KlarnaShippingType.pickupBox,
      'PICKUP_POINT': KlarnaShippingType.pickupPoint,
      'PICKUP_STORE': KlarnaShippingType.pickupStore,
      'PICKUP_WAREHOUSE': KlarnaShippingType.pickupWarehouse,
      'TO_CURB': KlarnaShippingType.toCurb,
      'TO_DOOR': KlarnaShippingType.toDoor,
      'TO_MAILBOX': KlarnaShippingType.toMailbox,
    },
    'shippingType');

KlarnaShippingTypeAttribute _shippingTypeAttribute(String v) => _byWire(
    v,
    {
      'CONTACTLESS_DELIVERY': KlarnaShippingTypeAttribute.contactlessDelivery,
      'EXPRESS': KlarnaShippingTypeAttribute.express,
      'IDENTIFICATION_REQUIRED':
          KlarnaShippingTypeAttribute.identificationRequired,
      'LEAVE_AT_CURB': KlarnaShippingTypeAttribute.leaveAtCurb,
      'LEAVE_AT_DOOR': KlarnaShippingTypeAttribute.leaveAtDoor,
      'LEAVE_WITH_NEIGHBOUR': KlarnaShippingTypeAttribute.leaveWithNeighbour,
      'SIGNATURE_REQUIRED': KlarnaShippingTypeAttribute.signatureRequired,
      'TRACKED': KlarnaShippingTypeAttribute.tracked,
      'UNTRACKED': KlarnaShippingTypeAttribute.untracked,
    },
    'shippingTypeAttributes');

KlarnaInterval _interval(String v) => _byWire(
    v,
    {
      'DAY': KlarnaInterval.day,
      'WEEK': KlarnaInterval.week,
      'MONTH': KlarnaInterval.month,
      'YEAR': KlarnaInterval.year,
    },
    'interval');

KlarnaFreeTrial _freeTrial(String v) => _byWire(
    v,
    {
      'ACTIVE': KlarnaFreeTrial.active,
      'INACTIVE': KlarnaFreeTrial.inactive,
    },
    'freeTrial');

T _byWire<T>(String value, Map<String, T> table, String field) {
  final result = table[value];
  if (result == null) {
    throw FormatException(
      "Unknown value '$value' for '$field'. Expected one of: "
      '${table.keys.join(', ')}',
    );
  }
  return result;
}

R? _map<R>(Object? value, R Function(Map<String, dynamic>) decode) =>
    value == null ? null : decode(value as Map<String, dynamic>);

List<R>? _objList<R>(Object? value, R Function(Map<String, dynamic>) decode) =>
    value == null
        ? null
        : [
            for (final e in value as List)
              decode((e as Map).cast<String, dynamic>())
          ];

List<T?>? _enumList<T>(Object? value, T Function(String) decode) =>
    value == null ? null : [for (final e in value as List) decode(e as String)];

List<String>? _stringList(Object? value) =>
    value == null ? null : [for (final e in value as List) e as String];

String _requireString(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is! String) {
    throw FormatException("Missing or non-string required field '$key'.");
  }
  return v;
}

int _requireInt(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is! int) {
    throw FormatException("Missing or non-integer required field '$key'.");
  }
  return v;
}
