import Flutter
import KlarnaNetworkCore
import KlarnaNetworkPayment
import UIKit
@_spi(FlutterKlarnaNetworkCore) import klarna_network_core

private let knDateOnlyPattern = #"^\d{4}-\d{2}-\d{2}$"#
private let knInternetDateTimePattern =
  #"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,9})?(?:Z|[+-]\d{2}:\d{2})$"#

func parseKnISO8601Date(_ value: String?) -> Date? {
  guard let value else { return nil }

  if value.range(of: knDateOnlyPattern, options: .regularExpression)
    == value.startIndex..<value.endIndex
  {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.isLenient = false
    return formatter.date(from: value)
  }

  guard value.range(of: knInternetDateTimePattern, options: .regularExpression)
    == value.startIndex..<value.endIndex
  else { return nil }

  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime]
  var normalizedValue = value
  if let fractionStart = value.firstIndex(of: "."),
    let zoneStart = value[value.index(after: fractionStart)...]
      .firstIndex(where: { $0 == "Z" || $0 == "+" || $0 == "-" })
  {
    let fraction = value[value.index(after: fractionStart)..<zoneStart]
    let milliseconds = String(fraction.prefix(3)).padding(
      toLength: 3,
      withPad: "0",
      startingAt: 0
    )
    normalizedValue =
      String(value[..<fractionStart]) + "." + milliseconds + String(value[zoneStart...])
    formatter.formatOptions.insert(.withFractionalSeconds)
  }
  return formatter.date(from: normalizedValue)
}

struct KnPaymentValidationError: Error {
  let message: String
}

func knCheckedInt32(_ value: Int64, field: String) throws -> Int32 {
  guard let result = Int32(exactly: value) else {
    throw KnPaymentValidationError(
      message:
        "\(field) must be between \(Int32.min) and \(Int32.max); got \(value)."
    )
  }
  return result
}

func requireKnBillingPlanDate(_ value: String) throws -> Date {
  guard let date = parseKnISO8601Date(value) else {
    throw KnPaymentValidationError(
      message:
        "billingPlan.from must be YYYY-MM-DD or an RFC 3339 timestamp; got '\(value)'."
    )
  }
  return date
}

/// Plugin entry point: registers the Pigeon host API and the Klarna Payment Button view.
public class KlarnaNetworkPaymentPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()

    let api = KnPaymentHostApiImpl()
    KnPaymentHostApiSetup.setUp(binaryMessenger: messenger, api: api)

    let factory = KlarnaPaymentButtonFactory(messenger: messenger)
    registrar.register(factory, withId: "com.klarna.mobile.sdk/payment_button")
  }
}

/// Host API implementation backed by the KlarnaNetworkPayment SDK. The `Klarna`
/// instance is resolved from the core plugin's `KnInstanceStore` by instanceId.
final class KnPaymentHostApiImpl: KnPaymentHostApi {
  private static let moduleName = "KlarnaNetworkPayment"
  private static let errorInstanceNotFound =
    "No instance found for the given instanceId. Call initialize first."
  private static let errorNoPresentationContent =
    "No presentation content found. Call presentationFetch first."
  private static let invalidRequestData = "InvalidRequestData"

  private let presentationStore =
    PresentationContentStore<KlarnaPaymentPresentationContent>()

  private func sdk(for instanceId: String) -> Klarna? {
    KnInstanceStore.shared.getInstance(instanceId)
  }

  private func validationFailure<T>(
    _ error: KnPaymentValidationError,
    _ completion: @escaping (Result<T, Error>) -> Void
  ) {
    completion(.failure(PigeonError(
      code: Self.invalidRequestData, message: error.message, details: nil)))
  }

  private func instanceNotFound() -> PigeonError {
    PigeonError(
      code: Self.moduleName, message: Self.errorInstanceNotFound, details: nil)
  }

  func initiateWithId(
    instanceId: String, paymentRequestId: String,
    completion: @escaping (Result<KnPaymentRequest, Error>) -> Void
  ) {
    guard let sdk = sdk(for: instanceId) else {
      completion(.failure(instanceNotFound()))
      return
    }
    sdk.payment.initiate(paymentRequestId: paymentRequestId) { result in
      self.complete(result, completion)
    }
  }

  func initiateWithData(
    instanceId: String, data: KnPaymentRequestData,
    completion: @escaping (Result<KnPaymentRequest, Error>) -> Void
  ) {
    guard let sdk = sdk(for: instanceId) else {
      completion(.failure(instanceNotFound()))
      return
    }
    let requestData: KlarnaPaymentRequestData
    do {
      requestData = KlarnaPaymentRequestData(
        amount: data.amount,
        currency: data.currency,
        paymentOptionId: data.paymentOptionId,
        paymentRequestReference: data.paymentRequestReference,
        requestCustomerToken: Self.map(data.requestCustomerToken),
        shippingConfig: Self.map(data.shippingConfig),
        collectCustomerProfile: Self.mapCollectCustomerProfile(data.collectCustomerProfile),
        supplementaryPurchaseData: try Self.map(data.supplementaryPurchaseData)
      )
    } catch let error as KnPaymentValidationError {
      validationFailure(error, completion)
      return
    } catch {
      completion(.failure(error))
      return
    }
    sdk.payment.initiate(paymentRequestData: requestData) { result in
      self.complete(result, completion)
    }
  }

  func fetch(
    instanceId: String, paymentRequestId: String,
    completion: @escaping (Result<KnPaymentRequest, Error>) -> Void
  ) {
    guard let sdk = sdk(for: instanceId) else {
      completion(.failure(instanceNotFound()))
      return
    }
    sdk.payment.fetch(paymentRequestId: paymentRequestId) { result in
      self.complete(result, completion)
    }
  }

  func cancel(
    instanceId: String, paymentRequestId: String,
    completion: @escaping (Result<KnPaymentRequest, Error>) -> Void
  ) {
    guard let sdk = sdk(for: instanceId) else {
      completion(.failure(instanceNotFound()))
      return
    }
    sdk.payment.cancel(paymentRequestId: paymentRequestId) { result in
      self.complete(result, completion)
    }
  }

  func presentationFetch(
    instanceId: String, data: KnPresentationData,
    completion: @escaping (Result<KnPresentationContent, Error>) -> Void
  ) {
    guard let sdk = sdk(for: instanceId) else {
      completion(.failure(instanceNotFound()))
      return
    }
    let frequency: Int?
    do {
      frequency = try data.subscriptionBillingIntervalFrequency.map {
        Int(try knCheckedInt32($0, field: "subscriptionBillingIntervalFrequency"))
      }
    } catch let error as KnPaymentValidationError {
      validationFailure(error, completion)
      return
    } catch {
      completion(.failure(error))
      return
    }
    let presentationData = KlarnaPaymentPresentationData(
      amount: data.amount,
      currency: data.currency,
      intent: data.intent.map(Self.map),
      paymentProgramEnablementCodes: data.paymentProgramEnablementCodes,
      subscriptionBillingInterval: data.subscriptionBillingInterval.map(Self.map),
      subscriptionBillingIntervalFrequency: frequency
    )
    let generation = presentationStore.beginRequest(instanceId)
    DispatchQueue.main.async {
      sdk.payment.presentation.fetch(data: presentationData) { [weak self] result in
        switch result {
        case .success(let content):
          // Only cache if the instance still exists — a dispose racing this
          // in-flight fetch must not repopulate the store.
          if self?.sdk(for: instanceId) != nil {
            self?.presentationStore.storeIfCurrent(instanceId, generation, content)
          }
          completion(.success(Self.map(content)))
        case .failure(let error):
          completion(.failure(PigeonError(code: error.name, message: error.message, details: nil)))
        }
      }
    }
  }

  func presentationHandleLink(
    instanceId: String, url: String,
    completion: @escaping (Result<KnPresentationContent, Error>) -> Void
  ) {
    guard let sdk = sdk(for: instanceId) else {
      completion(.failure(instanceNotFound()))
      return
    }
    guard let request = presentationStore.beginRequestWithContent(instanceId) else {
      completion(.failure(PigeonError(
        code: Self.moduleName, message: Self.errorNoPresentationContent, details: nil)))
      return
    }
    DispatchQueue.main.async {
      sdk.payment.presentation.handleLink(content: request.content, url: url) { [weak self] result in
        switch result {
        case .success(let newContent):
          // Guard against a dispose racing this in-flight handleLink (see fetch).
          if self?.sdk(for: instanceId) != nil {
            self?.presentationStore.storeIfCurrent(
              instanceId, request.generation, newContent)
          }
          completion(.success(Self.map(newContent)))
        case .failure(let error):
          completion(.failure(PigeonError(code: error.name, message: error.message, details: nil)))
        }
      }
    }
  }

  private func complete(
    _ result: Result<KlarnaPaymentRequest, KlarnaSDKError>,
    _ completion: @escaping (Result<KnPaymentRequest, Error>) -> Void
  ) {
    switch result {
    case .success(let request):
      completion(.success(Self.map(request)))
    case .failure(let error):
      completion(.failure(PigeonError(code: error.name, message: error.message, details: nil)))
    }
  }

  // Pigeon `Kn*` enums serialize by index, native `Klarna*` enums are String-raw,
  // so `.rawValue` can't bridge them — each pair is mapped by name.
  private static func map(_ request: KlarnaPaymentRequest) -> KnPaymentRequest {
    KnPaymentRequest(
      paymentRequestId: request.paymentRequestId,
      state: map(request.state),
      previousState: request.previousState.map(map),
      stateReason: request.stateReason.flatMap(map),
      paymentRequestReference: request.paymentRequestReference,
      stateContext: map(request.stateContext)
    )
  }

  private static func map(_ state: KlarnaPaymentRequestState) -> KnPaymentRequestState {
    switch state {
    case .submitted: return .submitted
    case .inProgress: return .inProgress
    case .completed: return .completed
    case .expired: return .expired
    case .canceled: return .canceled
    case .declined: return .declined
    @unknown default: return .inProgress
    }
  }

  private static func map(_ scope: KnRequestCustomerTokenScope) -> KlarnaRequestCustomerTokenScope {
    switch scope {
    case .customerLogin: return .customerLogin
    case .paymentCustomerNotPresent: return .paymentCustomerNotPresent
    case .paymentCustomerPresent: return .paymentCustomerPresent
    }
  }

  private static func map(_ mode: KnShippingConfigMode) -> KlarnaShippingConfigMode {
    switch mode {
    case .editable: return .editable
    }
  }

  private static func map(
    _ type: KnCollectCustomerProfileType
  ) -> KlarnaCollectCustomerProfileType {
    switch type {
    case .billingAddress: return .billingAddress
    case .country: return .country
    case .dateOfBirth: return .dateOfBirth
    case .email: return .email
    case .locale: return .locale
    case .name: return .name
    case .nationalIdentification: return .nationalIdentification
    case .phone: return .phone
    }
  }

  private static func map(_ type: KnShippingType) -> KlarnaShippingType {
    switch type {
    case .digitalDownload: return .digitalDownload
    case .digitalEmail: return .digitalEmail
    case .digitalOther: return .digitalOther
    case .physicalOther: return .physicalOther
    case .pickupBox: return .pickupBox
    case .pickupPoint: return .pickupPoint
    case .pickupStore: return .pickupStore
    case .pickupWarehouse: return .pickupWarehouse
    case .toCurb: return .toCurb
    case .toDoor: return .toDoor
    case .toMailbox: return .toMailbox
    }
  }

  private static func map(
    _ attribute: KnShippingTypeAttribute
  ) -> KlarnaShippingTypeAttribute {
    switch attribute {
    case .contactlessDelivery: return .contactlessDelivery
    case .express: return .express
    case .identificationRequired: return .identificationRequired
    case .leaveAtCurb: return .leaveAtCurb
    case .leaveAtDoor: return .leaveAtDoor
    case .leaveWithNeighbour: return .leaveWithNeighbour
    case .signatureRequired: return .signatureRequired
    case .tracked: return .tracked
    case .untracked: return .untracked
    }
  }

  private static func map(_ interval: KnInterval) -> KlarnaInterval {
    switch interval {
    case .day: return .day
    case .week: return .week
    case .month: return .month
    case .year: return .year
    }
  }

  private static func map(_ freeTrial: KnFreeTrial) -> KlarnaFreeTrial {
    switch freeTrial {
    case .active: return .active
    case .inactive: return .inactive
    }
  }

  private static func map(
    _ intent: KnPresentationIntent
  ) -> KlarnaPaymentPresentationIntent {
    switch intent {
    case .pay: return .pay
    case .subscribe: return .subscribe
    case .addToWallet: return .addToWallet
    }
  }

  private static func map(
    _ reason: KlarnaPaymentRequestStateReason
  ) -> KnPaymentRequestStateReason {
    switch reason {
    case .partnerCanceled: return .partnerCanceled
    case .paymentRequestSubmitted: return .paymentRequestSubmitted
    case .purchaseFlowAborted: return .purchaseFlowAborted
    case .technicalError: return .technicalError
    case .paymentDeclined: return .paymentDeclined
    @unknown default: return .technicalError
    }
  }

  private static func map(_ type: KlarnaShippingType) -> KnShippingType {
    switch type {
    case .digitalDownload: return .digitalDownload
    case .digitalEmail: return .digitalEmail
    case .digitalOther: return .digitalOther
    case .physicalOther: return .physicalOther
    case .pickupBox: return .pickupBox
    case .pickupPoint: return .pickupPoint
    case .pickupStore: return .pickupStore
    case .pickupWarehouse: return .pickupWarehouse
    case .toCurb: return .toCurb
    case .toDoor: return .toDoor
    case .toMailbox: return .toMailbox
    @unknown default: return .digitalOther
    }
  }

  private static func map(
    _ attribute: KlarnaShippingTypeAttribute
  ) -> KnShippingTypeAttribute {
    switch attribute {
    case .contactlessDelivery: return .contactlessDelivery
    case .express: return .express
    case .identificationRequired: return .identificationRequired
    case .leaveAtCurb: return .leaveAtCurb
    case .leaveAtDoor: return .leaveAtDoor
    case .leaveWithNeighbour: return .leaveWithNeighbour
    case .signatureRequired: return .signatureRequired
    case .tracked: return .tracked
    case .untracked: return .untracked
    @unknown default: return .untracked
    }
  }

  private static func map(
    _ instruction: KlarnaPaymentPresentationInstruction
  ) -> KnPresentationInstruction {
    switch instruction {
    case .showKlarna: return .showKlarna
    case .preselectKlarna: return .preselectKlarna
    case .showOnlyKlarna: return .showOnlyKlarna
    @unknown default: return .showKlarna
    }
  }

  private static func map(
    _ status: KlarnaPaymentPresentationPaymentStatus
  ) -> KnPresentationPaymentStatus {
    switch status {
    case .pendingPartnerAuthorization: return .pendingPartnerAuthorization
    case .requiresCustomerAction: return .requiresCustomerAction
    @unknown default: return .requiresCustomerAction
    }
  }

  private static func map(
    _ alignment: KlarnaPaymentPresentationImageAlignment
  ) -> KnPresentationImageAlignment {
    switch alignment {
    case .left: return .left
    case .right: return .right
    @unknown default: return .left
    }
  }

  private static func map(
    _ style: KlarnaPaymentPresentationTextPartStyle
  ) -> KnPresentationTextPartStyle {
    switch style {
    case .bold: return .bold
    case .italic: return .italic
    case .underline: return .underline
    @unknown default: return .bold
    }
  }

  private static func map(
    _ context: KlarnaPaymentPresentationTextPartLinkContext
  ) -> KnPresentationTextPartLinkContext {
    switch context {
    case .auth: return .auth
    case .info: return .info
    @unknown default: return .info
    }
  }

  private static func map(_ token: KnRequestCustomerToken?) -> KlarnaRequestCustomerToken? {
    guard let token else { return nil }
    let scopes = token.scopes.compactMap { $0.flatMap(map) }
    return KlarnaRequestCustomerToken(
      scopes: scopes,
      customerTokenReference: token.customerTokenReference
    )
  }

  private static func map(_ config: KnShippingConfig?) -> KlarnaShippingConfig? {
    guard let config else { return nil }
    return KlarnaShippingConfig(supportedCountries: config.supportedCountries, mode: map(config.mode))
  }

  static func mapCollectCustomerProfile(
    _ raw: [KnCollectCustomerProfileType?]?
  ) -> [KlarnaCollectCustomerProfileType]? {
    guard let raw else { return nil }
    return raw.compactMap { $0.map(map) }
  }

  private static func map(
    _ data: KnSupplementaryPurchaseData?
  ) throws -> KlarnaSupplementaryPurchaseData? {
    guard let data else { return nil }
    return KlarnaSupplementaryPurchaseData(
      customer: map(data.customer),
      lineItems: try data.lineItems?.map { try map($0) },
      purchaseReference: data.purchaseReference,
      shipping: data.shipping?.map { map($0) },
      ondemandService: try data.ondemandService.map { try map($0) },
      subscriptions: try data.subscriptions?.map { try map($0) }
    )
  }

  private static func map(_ customer: KnPartnerCustomer?) -> KlarnaPartnerCustomer? {
    guard let customer else { return nil }
    return KlarnaPartnerCustomer(
      address: map(customer.address),
      email: customer.email,
      familyName: customer.familyName,
      givenName: customer.givenName,
      phone: customer.phone
    )
  }

  private static func map(_ address: KnAddress?) -> KlarnaAddress? {
    guard let address else { return nil }
    return KlarnaAddress(
      city: address.city,
      country: address.country,
      postalCode: address.postalCode,
      region: address.region,
      streetAddress: address.streetAddress,
      streetAddress2: address.streetAddress2
    )
  }

  private static func map(_ item: KnLineItem) throws -> KlarnaLineItem {
    KlarnaLineItem(
      currency: item.currency,
      imageUrl: item.imageUrl,
      name: item.name,
      productIdentifier: item.productIdentifier,
      productUrl: item.productUrl,
      lineItemReference: item.lineItemReference,
      shippingReference: item.shippingReference,
      subscriptionReference: item.subscriptionReference,
      quantity: Int(try knCheckedInt32(item.quantity, field: "lineItem.quantity")),
      totalAmount: item.totalAmount,
      totalTaxAmount: item.totalTaxAmount,
      unitPrice: item.unitPrice
    )
  }

  private static func map(_ shipping: KnShipping) -> KlarnaShipping {
    KlarnaShipping(
      address: map(shipping.address),
      recipient: map(shipping.recipient),
      shippingOption: map(shipping.shippingOption),
      shippingReference: shipping.shippingReference
    )
  }

  private static func map(_ recipient: KnShippingRecipient?) -> KlarnaShippingRecipient? {
    guard let recipient else { return nil }
    return KlarnaShippingRecipient(
      attention: recipient.attention,
      email: recipient.email,
      familyName: recipient.familyName,
      givenName: recipient.givenName,
      phone: recipient.phone
    )
  }

  private static func map(_ option: KnShippingOption?) -> KlarnaShippingOption? {
    guard let option else { return nil }
    let attributes = option.shippingTypeAttributes?
      .compactMap { $0.map(map) }
    return KlarnaShippingOption(
      shippingCarrier: option.shippingCarrier,
      shippingType: map(option.shippingType),
      shippingTypeAttributes: attributes
    )
  }

  private static func map(_ service: KnOndemandService) throws -> KlarnaOndemandService {
    return KlarnaOndemandService(
      currency: service.currency,
      averageAmount: service.averageAmount,
      minimumAmount: service.minimumAmount,
      maximumAmount: service.maximumAmount,
      purchaseInterval: service.purchaseInterval.flatMap(map),
      purchaseIntervalFrequency: try service.purchaseIntervalFrequency.map {
        try knCheckedInt32($0, field: "ondemandService.purchaseIntervalFrequency")
      }
    )
  }

  private static func map(_ subscription: KnSubscription) throws -> KlarnaSubscription {
    KlarnaSubscription(
      subscriptionReference: subscription.subscriptionReference,
      name: subscription.name,
      freeTrial: subscription.freeTrial.flatMap(map),
      billingPlans: try subscription.billingPlans?.map { try map($0) }
    )
  }

  private static func map(_ plan: KnBillingPlan) throws -> KlarnaBillingPlan {
    return KlarnaBillingPlan(
      billingAmount: plan.billingAmount,
      currency: plan.currency,
      from: try requireKnBillingPlanDate(plan.from),
      interval: map(plan.interval),
      intervalFrequency:
        try knCheckedInt32(plan.intervalFrequency, field: "billingPlan.intervalFrequency")
    )
  }

  private static func map(_ context: KlarnaPaymentRequestStateContext?) -> KnPaymentRequestStateContext? {
    guard let context else { return nil }
    return KnPaymentRequestStateContext(
      klarnaNetworkSessionToken: context.klarnaNetworkSessionToken,
      klarnaCustomer: map(context.klarnaCustomer),
      shipping: map(context.shipping)
    )
  }

  private static func map(_ customer: KlarnaCustomer?) -> KnCustomer? {
    guard let customer else { return nil }
    return KnCustomer(
      customerToken: customer.customerToken,
      customerTokenReference: customer.customerTokenReference,
      customerProfile: map(customer.customerProfile)
    )
  }

  private static func map(_ profile: KlarnaCustomerProfile?) -> KnCustomerProfile? {
    guard let profile else { return nil }
    return KnCustomerProfile(
      address: map(profile.address),
      customerId: profile.customerId,
      country: profile.country,
      email: profile.email,
      emailVerified: profile.emailVerified,
      familyName: profile.familyName,
      givenName: profile.givenName,
      locale: profile.locale,
      phone: profile.phone,
      phoneVerified: profile.phoneVerified
    )
  }

  private static func map(_ address: KlarnaAddress?) -> KnAddress? {
    guard let address else { return nil }
    return KnAddress(
      streetAddress: address.streetAddress,
      streetAddress2: address.streetAddress2,
      city: address.city,
      region: address.region,
      postalCode: address.postalCode,
      country: address.country
    )
  }

  private static func map(_ shipping: KlarnaShipping?) -> KnShipping? {
    guard let shipping else { return nil }
    return KnShipping(
      address: map(shipping.address),
      recipient: map(shipping.recipient),
      shippingOption: map(shipping.shippingOption),
      shippingReference: shipping.shippingReference
    )
  }

  private static func map(_ recipient: KlarnaShippingRecipient?) -> KnShippingRecipient? {
    guard let recipient else { return nil }
    return KnShippingRecipient(
      familyName: recipient.familyName,
      givenName: recipient.givenName,
      attention: recipient.attention,
      email: recipient.email,
      phone: recipient.phone
    )
  }

  private static func map(_ option: KlarnaShippingOption?) -> KnShippingOption? {
    guard let option else { return nil }
    return KnShippingOption(
      shippingType: map(option.shippingType),
      shippingCarrier: option.shippingCarrier,
      shippingTypeAttributes: option.shippingTypeAttributes?.map { map($0) }
    )
  }

  private static func map(_ content: KlarnaPaymentPresentationContent) -> KnPresentationContent {
    KnPresentationContent(
      instruction: map(content.instruction),
      paymentStatus: content.paymentStatus.map(map),
      paymentOption: map(content.paymentOption),
      savedPaymentOption: map(content.savedPaymentOption)
    )
  }

  private static func map(
    _ option: KlarnaPaymentPresentationPaymentOption?
  ) -> KnPresentationPaymentOption? {
    guard let option else { return nil }
    return KnPresentationPaymentOption(
      paymentOptionId: option.paymentOptionId,
      header: mapPresentationText(option.header),
      badge: mapPresentationText(option.badge),
      subheader: mapPresentationText(option.subheader),
      message: mapPresentationText(option.message),
      terms: mapPresentationText(option.terms),
      paymentButton: map(option.paymentButton),
      icon: map(option.icon)
    )
  }

  static func mapPresentationText(
    _ text: KlarnaPaymentPresentationText.PlainText?
  ) -> KnPresentationText? {
    guard let text else { return nil }
    return KnPresentationText(type: "plainText", text: text.text, parts: nil)
  }

  static func mapPresentationText(
    _ text: KlarnaPaymentPresentationText.AttributedText?
  ) -> KnPresentationText? {
    guard let text else { return nil }
    return KnPresentationText(
      type: "attributedText",
      text: nil,
      parts: text.parts?.map { map($0) }
    )
  }

  private static func map(_ part: KlarnaPaymentPresentationTextPart) -> KnPresentationTextPart {
    switch part {
    case .plainText(let styles, let text):
      return KnPresentationTextPart(
        type: "plain",
        text: text,
        url: nil,
        context: nil,
        styles: styles?.map { map($0) as KnPresentationTextPartStyle? }
      )
    case .link(let styles, let text, let url, let context):
      return KnPresentationTextPart(
        type: "link",
        text: text,
        url: url,
        context: context.map(map),
        styles: styles?.map { map($0) as KnPresentationTextPartStyle? }
      )
    }
  }

  private static func map(
    _ button: KlarnaPaymentPresentationPaymentButton?
  ) -> KnPresentationPaymentButton? {
    guard let button else { return nil }
    return KnPresentationPaymentButton(
      text: button.text,
      imageUrl: button.imageUrl,
      imageAlignment: button.imageAlignment.map(map)
    )
  }

  private static func map(_ icon: KlarnaPaymentPresentationIcon?) -> KnPresentationIcon? {
    guard let icon else { return nil }
    return KnPresentationIcon(
      alt: icon.alt,
      badgeImageUrl: icon.badgeImageUrl,
      rectangleImageUrl: icon.rectangleImageUrl,
      squareImageUrl: icon.squareImageUrl
    )
  }
}

final class PresentationContentStore<Content> {
  struct Request {
    let generation: UInt64
    let content: Content
  }

  private struct State {
    var generation: UInt64
    var content: Content?
  }

  private let queue = DispatchQueue(label: "com.klarna.flutter.knpayment.presentationcontent")
  private var storage: [String: State] = [:]
  private var nextGeneration: UInt64 = 0

  func beginRequest(_ key: String) -> UInt64 {
    queue.sync {
      let generation = makeGeneration()
      storage[key] = State(
        generation: generation,
        content: storage[key]?.content
      )
      return generation
    }
  }

  func beginRequestWithContent(_ key: String) -> Request? {
    queue.sync {
      guard let content = storage[key]?.content else { return nil }
      let generation = makeGeneration()
      storage[key] = State(generation: generation, content: content)
      return Request(generation: generation, content: content)
    }
  }

  @discardableResult
  func storeIfCurrent(
    _ key: String, _ generation: UInt64, _ content: Content
  ) -> Bool {
    queue.sync {
      guard var state = storage[key], state.generation == generation else {
        return false
      }
      state.content = content
      storage[key] = state
      return true
    }
  }

  func invalidate(_ key: String) {
    queue.sync {
      storage.removeValue(forKey: key)
    }
  }

  var stateCount: Int { queue.sync { storage.count } }

  private func makeGeneration() -> UInt64 {
    precondition(
      nextGeneration < UInt64.max,
      "Presentation request generation exhausted."
    )
    nextGeneration += 1
    return nextGeneration
  }
}
