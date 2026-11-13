import Flutter
import KlarnaNetworkMessaging
import XCTest

@_spi(KLARNA) import KlarnaNetworkCore

@testable import klarna_network_messaging

final class KlarnaMessagingPrequalificationMappingTests: XCTestCase {
  func testApprovedMapsToApprovedWithExpiresAtMillis() {
    let result = KlarnaMessagingPrequalificationMapping.toKnResult(
      .approved(expiresAt: Date(timeIntervalSince1970: 1_798_761_600)))

    XCTAssertEqual(result.status, .approved)
    XCTAssertEqual(result.expiresAtMillis, 1_798_761_600_000)
  }

  func testApprovedKeepsMillisecondPrecision() {
    let result = KlarnaMessagingPrequalificationMapping.toKnResult(
      .approved(expiresAt: Date(timeIntervalSince1970: 1_798_761_600.123)))

    XCTAssertEqual(result.expiresAtMillis, 1_798_761_600_123)
  }

  func testAbortedMapsToAbortedWithoutExpiresAt() {
    let result = KlarnaMessagingPrequalificationMapping.toKnResult(.aborted)

    XCTAssertEqual(result.status, .aborted)
    XCTAssertNil(result.expiresAtMillis)
  }

  func testSuccessOutcomeMapsToSuccessResult() throws {
    let outcome = KlarnaMessagingPrequalificationMapping.toCompletionResult(
      .success(.approved(expiresAt: Date(timeIntervalSince1970: 42))))

    XCTAssertEqual(try outcome.get().expiresAtMillis, 42_000)
  }

  func testFailureOutcomeMapsNativeErrorNameAndMessage() {
    for name in ["OPERATION_FAILED", "INITIATE_ALREADY_IN_PROGRESS"] {
      let outcome = KlarnaMessagingPrequalificationMapping.toCompletionResult(
        .failure(KlarnaSDKError(name: name, message: "boom")))

      guard case .failure(let error) = outcome, let pigeonError = error as? PigeonError else {
        XCTFail("Expected a PigeonError failure for \(name)")
        continue
      }
      XCTAssertEqual(pigeonError.code, name)
      XCTAssertEqual(pigeonError.message, "boom")
    }
  }
}
