import XCTest
import KlarnaNetworkPayment
@testable import klarna_network_payment

final class KlarnaNetworkPaymentModelTests: XCTestCase {
  func testISO8601DateParserAcceptsSupportedDateForms() throws {
    let midnight = try XCTUnwrap(parseKnISO8601Date("2026-01-01T00:00:00Z"))

    XCTAssertEqual(midnight, try XCTUnwrap(parseKnISO8601Date("2026-01-01")))
    XCTAssertEqual(
      midnight,
      try XCTUnwrap(parseKnISO8601Date("2026-01-01T01:00:00+01:00"))
    )
    XCTAssertEqual(
      midnight,
      try XCTUnwrap(parseKnISO8601Date("2025-12-31T19:00:00-05:00"))
    )

    let milliseconds =
      try XCTUnwrap(parseKnISO8601Date("2026-01-01T00:00:00.123Z"))
    XCTAssertEqual(
      milliseconds,
      try XCTUnwrap(parseKnISO8601Date("2026-01-01T00:00:00.123456789Z"))
    )
    XCTAssertNotNil(parseKnISO8601Date("2026-01-01T00:00:00.1Z"))
  }

  func testISO8601DateParserRejectsMalformedOrPartialInput() {
    let invalidInputs = [
      "",
      "2026-02-30",
      "2026-01-01T00:00:00",
      "2026-01-01T00:00:00.Z",
      "2026-01-01T00:00:00+0100",
      "2026-01-01T00:00:00Ztrailing",
      "prefix2026-01-01T00:00:00Z",
    ]

    invalidInputs.forEach { XCTAssertNil(parseKnISO8601Date($0), $0) }
    XCTAssertNil(parseKnISO8601Date(nil))
  }

  func testInvalidBillingPlanDateThrowsValidationError() {
    XCTAssertThrowsError(try requireKnBillingPlanDate("2026-02-30")) { error in
      XCTAssertEqual(
        (error as? KnPaymentValidationError)?.message,
        "billingPlan.from must be YYYY-MM-DD or an RFC 3339 timestamp; got '2026-02-30'."
      )
    }
  }

  func testCheckedInt32AcceptsBoundariesAndRejectsOverflow() throws {
    XCTAssertEqual(
      try knCheckedInt32(Int64(Int32.min), field: "field"),
      Int32.min
    )
    XCTAssertEqual(
      try knCheckedInt32(Int64(Int32.max), field: "field"),
      Int32.max
    )
    XCTAssertThrowsError(
      try knCheckedInt32(Int64(Int32.min) - 1, field: "field")
    )
    XCTAssertThrowsError(
      try knCheckedInt32(Int64(Int32.max) + 1, field: "field")
    )
  }

  func testPresentationStoreRejectsOutOfOrderCompletions() throws {
    let store = PresentationContentStore<String>()
    let first = store.beginRequest("instance")
    let second = store.beginRequest("instance")

    XCTAssertFalse(store.storeIfCurrent("instance", first, "old"))
    XCTAssertTrue(store.storeIfCurrent("instance", second, "new"))

    let request = try XCTUnwrap(store.beginRequestWithContent("instance"))
    XCTAssertEqual(request.content, "new")
  }

  func testPresentationStoreRejectsCompletionAfterDispose() {
    let store = PresentationContentStore<String>()
    let request = store.beginRequest("instance")

    store.invalidate("instance")

    XCTAssertEqual(store.stateCount, 0)
    XCTAssertFalse(store.storeIfCurrent("instance", request, "stale"))
    XCTAssertNil(store.beginRequestWithContent("instance"))
  }

  func testPresentationStoreRejectsStaleCompletionAfterKeyReuse() {
    let store = PresentationContentStore<String>()
    let oldRequest = store.beginRequest("instance")

    store.invalidate("instance")
    let newRequest = store.beginRequest("instance")

    XCTAssertFalse(store.storeIfCurrent("instance", oldRequest, "old"))
    XCTAssertTrue(store.storeIfCurrent("instance", newRequest, "new"))
    XCTAssertEqual(store.stateCount, 1)
  }

  func testCollectCustomerProfilePreservesNullAndEmpty() {
    XCTAssertNil(KnPaymentHostApiImpl.mapCollectCustomerProfile(nil))
    XCTAssertEqual(
      KnPaymentHostApiImpl.mapCollectCustomerProfile([])?.count,
      0
    )
    XCTAssertEqual(
      KnPaymentHostApiImpl.mapCollectCustomerProfile([.email])?.count,
      1
    )
  }

  func testMapsNativePlainPresentationText() throws {
    let text = KlarnaPaymentPresentationText.PlainText(text: "Pay with Klarna")

    let mapped = try XCTUnwrap(KnPaymentHostApiImpl.mapPresentationText(text))

    XCTAssertEqual(mapped.type, "plainText")
    XCTAssertEqual(mapped.text, "Pay with Klarna")
    XCTAssertNil(mapped.parts)
  }

  func testMapsNativeAttributedPresentationTextParts() throws {
    let text = KlarnaPaymentPresentationText.AttributedText(
      parts: [
        .plainText(styles: [.bold], text: "Read"),
        .link(
          styles: [.underline],
          text: "terms",
          url: "https://klarna.com/terms",
          context: .info
        ),
      ]
    )

    let mapped = try XCTUnwrap(KnPaymentHostApiImpl.mapPresentationText(text))

    XCTAssertEqual(mapped.type, "attributedText")
    XCTAssertNil(mapped.text)
    XCTAssertEqual(mapped.parts?.first?.type, "plain")
    XCTAssertEqual(mapped.parts?.first?.styles, [.bold])
    XCTAssertEqual(mapped.parts?.last?.type, "link")
    XCTAssertEqual(mapped.parts?.last?.url, "https://klarna.com/terms")
    XCTAssertEqual(mapped.parts?.last?.context, .info)
  }

  func testPaymentRequestCarriesStructuredStateContext() {
    let request = KnPaymentRequest(
      paymentRequestId: "pr_123",
      state: .completed,
      previousState: .inProgress,
      stateReason: .paymentRequestSubmitted,
      paymentRequestReference: "merchant_ref",
      stateContext: KnPaymentRequestStateContext(
        klarnaNetworkSessionToken: "session-token",
        klarnaCustomer: KnCustomer(
          customerToken: "customer-token",
          customerTokenReference: "customer-ref",
          customerProfile: KnCustomerProfile(
            address: KnAddress(
              streetAddress: "Sveavagen 46",
              streetAddress2: nil,
              city: "Stockholm",
              region: nil,
              postalCode: "11134",
              country: "SE"
            ),
            customerId: "customer-id",
            country: "SE",
            email: "customer@example.com",
            emailVerified: true,
            familyName: "Customer",
            givenName: "Klarna",
            locale: "en-SE",
            phone: "+46700000000",
            phoneVerified: false
          )
        ),
        shipping: KnShipping(
          address: KnAddress(country: "SE"),
          recipient: KnShippingRecipient(
            familyName: "Customer",
            givenName: "Klarna"
          ),
          shippingOption: KnShippingOption(shippingType: .toDoor),
          shippingReference: "ship-1"
        )
      )
    )

    XCTAssertEqual(request.paymentRequestId, "pr_123")
    XCTAssertEqual(request.previousState, .inProgress)
    XCTAssertEqual(request.stateContext?.klarnaNetworkSessionToken, "session-token")
    XCTAssertEqual(request.stateContext?.klarnaCustomer?.customerProfile?.emailVerified, true)
    XCTAssertEqual(request.stateContext?.shipping?.shippingOption?.shippingType, .toDoor)
  }

  func testPresentationContentCarriesAttributedTextAndButtonAssets() {
    let content = KnPresentationContent(
      instruction: .showKlarna,
      paymentStatus: .requiresCustomerAction,
      paymentOption: KnPresentationPaymentOption(
        paymentOptionId: "pay_now",
        header: KnPresentationText(type: "plainText", text: "Pay with Klarna"),
        terms: KnPresentationText(
          type: "attributedText",
          parts: [
            KnPresentationTextPart(
              type: "plain",
              text: "Read ",
              styles: [.bold]
            ),
            KnPresentationTextPart(
              type: "link",
              text: "terms",
              url: "https://klarna.com/terms",
              context: .info,
              styles: [.underline]
            ),
          ]
        ),
        paymentButton: KnPresentationPaymentButton(
          text: "Continue",
          imageUrl: "https://cdn.klarna.com/button.png",
          imageAlignment: .left
        ),
        icon: KnPresentationIcon(alt: "Klarna")
      )
    )

    XCTAssertEqual(content.instruction, .showKlarna)
    XCTAssertEqual(content.paymentOption?.paymentOptionId, "pay_now")
    XCTAssertEqual(content.paymentOption?.terms?.parts?.last?.url, "https://klarna.com/terms")
    XCTAssertEqual(content.paymentOption?.paymentButton?.imageAlignment, .left)
  }

  func testPaymentButtonPropsMergeClearsNullableValues() {
    let initial = KlarnaPaymentButtonView.Props([
      "instanceId": "instance-id",
      "state": "loading",
      "intent": "pay",
      "shape": "pill",
      "buttonStyle": "outlined",
      "theme": "dark",
    ])

    let cleared = initial.merging([
      "state": NSNull(),
      "intent": NSNull(),
      "shape": NSNull(),
      "buttonStyle": NSNull(),
      "theme": NSNull(),
    ])

    XCTAssertEqual(cleared.instanceId, "instance-id")
    XCTAssertNil(cleared.state)
    XCTAssertNil(cleared.intent)
    XCTAssertNil(cleared.shape)
    XCTAssertNil(cleared.buttonStyle)
    XCTAssertNil(cleared.theme)
  }

  func testPaymentButtonPropsIgnoreNonNativeFieldsForEquality() {
    let initial = KlarnaPaymentButtonView.Props([
      "instanceId": "instance-id",
      "state": "loading",
      "intent": "pay",
      "shape": "pill",
      "buttonStyle": "outlined",
      "theme": "dark",
    ])
    let heightOnlyUpdate = initial.merging([
      "height": 72.0
    ])

    XCTAssertTrue(heightOnlyUpdate.hasSameNativeValues(as: initial))
  }

  func testPaymentButtonPropsDetectEveryNativeFieldChange() {
    let initialValues: [String: Any] = [
      "instanceId": "instance-id",
      "state": "loading",
      "intent": "pay",
      "shape": "pill",
      "buttonStyle": "outlined",
      "theme": "dark",
    ]
    let initial = KlarnaPaymentButtonView.Props(initialValues)

    for key in initialValues.keys {
      var changedValues = initialValues
      changedValues[key] = "changed"
      XCTAssertFalse(
        KlarnaPaymentButtonView.Props(changedValues)
          .hasSameNativeValues(as: initial),
        key
      )
    }
  }
}
