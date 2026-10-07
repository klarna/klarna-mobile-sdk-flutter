import XCTest

@testable import klarna_network_messaging

final class KlarnaMessagingParsingTests: XCTestCase {
  func testParseAmountReturnsNilForEmptyOrInvalid() {
    XCTAssertNil(KlarnaMessagingParsing.parseAmount(nil))
    XCTAssertNil(KlarnaMessagingParsing.parseAmount(""))
    XCTAssertNil(KlarnaMessagingParsing.parseAmount("abc"))
    XCTAssertNil(KlarnaMessagingParsing.parseAmount("12.5"))
  }

  func testParseAmountParsesIntegers() {
    XCTAssertEqual(KlarnaMessagingParsing.parseAmount("0"), 0)
    XCTAssertEqual(KlarnaMessagingParsing.parseAmount("19900"), 19900)
  }

  func testResolvePlacementKindDefaultsToAutoSize() {
    XCTAssertEqual(KlarnaMessagingParsing.resolvePlacementKind(nil), .autoSize)
    XCTAssertEqual(KlarnaMessagingParsing.resolvePlacementKind("unknown"), .autoSize)
    XCTAssertEqual(
      KlarnaMessagingParsing.resolvePlacementKind("CreditPromotionAutoSize"), .autoSize)
  }

  func testResolvePlacementKindResolvesBadge() {
    XCTAssertEqual(
      KlarnaMessagingParsing.resolvePlacementKind("CreditPromotionBadge"), .badge)
  }

  func testResolveThemeKindMapsKnownValues() {
    XCTAssertEqual(KlarnaMessagingParsing.resolveThemeKind("light"), .light)
    XCTAssertEqual(KlarnaMessagingParsing.resolveThemeKind("dark"), .dark)
    XCTAssertEqual(KlarnaMessagingParsing.resolveThemeKind("automatic"), .automatic)
  }

  func testResolveThemeKindReturnsNilForUnknownOrEmpty() {
    XCTAssertNil(KlarnaMessagingParsing.resolveThemeKind(nil))
    XCTAssertNil(KlarnaMessagingParsing.resolveThemeKind(""))
    XCTAssertNil(KlarnaMessagingParsing.resolveThemeKind("teal"))
  }
}
