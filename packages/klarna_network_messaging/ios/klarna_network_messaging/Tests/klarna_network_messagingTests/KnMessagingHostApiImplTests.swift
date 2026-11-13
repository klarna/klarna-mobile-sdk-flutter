import Flutter
import XCTest

@testable import klarna_network_messaging

final class KnMessagingHostApiImplTests: XCTestCase {
  func testUnknownInstanceFailsWithInstanceNotFound() {
    var outcome: Result<KnPrequalificationResult, Error>?

    KnMessagingHostApiImpl().prequalificationInitiate(
      instanceId: "missing-instance",
      data: KnPrequalificationData(amount: 1000, currency: "USD")
    ) { outcome = $0 }

    guard case .failure(let error)? = outcome, let pigeonError = error as? PigeonError else {
      XCTFail("Expected a PigeonError failure")
      return
    }
    XCTAssertEqual(pigeonError.code, "KlarnaNetworkMessaging")
    XCTAssertEqual(
      pigeonError.message, "No instance found for the given instanceId. Call initialize first.")
  }
}
