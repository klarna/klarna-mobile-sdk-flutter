import KlarnaMobileSDK
import XCTest
@testable import klarna_mobile_sdk_flutter

/// Tests the string -> Klarna enum mapping, including case-insensitivity and
/// the documented defaults used when a value is missing or unrecognized.
class KlarnaParamMapperTests: XCTestCase {

    // MARK: - Environment

    func testEnvironmentMapsKnownValuesCaseInsensitively() {
        XCTAssertEqual(
            KlarnaParamMapper.getEnvironment(param: "playground"), .playground)
        XCTAssertEqual(
            KlarnaParamMapper.getEnvironment(param: "PLAYGROUND"), .playground)
        XCTAssertEqual(
            KlarnaParamMapper.getEnvironment(param: "staging"), .staging)
        XCTAssertEqual(
            KlarnaParamMapper.getEnvironment(param: "production"), .production)
    }

    func testEnvironmentReturnsNilForUnknownOrNil() {
        XCTAssertNil(KlarnaParamMapper.getEnvironment(param: "nope"))
        XCTAssertNil(KlarnaParamMapper.getEnvironment(param: nil))
    }

    func testEnvironmentDefaultIsProduction() {
        XCTAssertEqual(
            KlarnaParamMapper.getEnvironmentOrDefault(param: nil), .production)
        XCTAssertEqual(
            KlarnaParamMapper.getEnvironmentOrDefault(param: "garbage"),
            .production)
        XCTAssertEqual(
            KlarnaParamMapper.getEnvironmentOrDefault(param: "STAGING"),
            .staging)
    }

    // MARK: - Region

    func testRegionMapsKnownValuesCaseInsensitively() {
        XCTAssertEqual(KlarnaParamMapper.getRegion(param: "eu"), .eu)
        XCTAssertEqual(KlarnaParamMapper.getRegion(param: "EU"), .eu)
        XCTAssertEqual(KlarnaParamMapper.getRegion(param: "na"), .na)
        XCTAssertEqual(KlarnaParamMapper.getRegion(param: "oc"), .oc)
    }

    func testRegionReturnsNilForUnknownOrNil() {
        XCTAssertNil(KlarnaParamMapper.getRegion(param: "xx"))
        XCTAssertNil(KlarnaParamMapper.getRegion(param: nil))
    }

    func testRegionDefaultIsEu() {
        XCTAssertEqual(KlarnaParamMapper.getRegionOrDefault(param: nil), .eu)
        XCTAssertEqual(
            KlarnaParamMapper.getRegionOrDefault(param: "garbage"), .eu)
        XCTAssertEqual(KlarnaParamMapper.getRegionOrDefault(param: "NA"), .na)
    }

    // MARK: - Resource endpoint

    func testResourceEndpointMapsKnownValuesCaseInsensitively() {
        XCTAssertEqual(
            KlarnaParamMapper.getResourceEndpoint(param: "alternative_1"),
            .alternative1)
        XCTAssertEqual(
            KlarnaParamMapper.getResourceEndpoint(param: "ALTERNATIVE_1"),
            .alternative1)
        XCTAssertEqual(
            KlarnaParamMapper.getResourceEndpoint(param: "alternative_2"),
            .alternative2)
    }

    func testResourceEndpointReturnsNilForUnknownOrNil() {
        XCTAssertNil(KlarnaParamMapper.getResourceEndpoint(param: "alternative_9"))
        XCTAssertNil(KlarnaParamMapper.getResourceEndpoint(param: nil))
    }

    func testResourceEndpointDefaultIsAlternative1() {
        XCTAssertEqual(
            KlarnaParamMapper.getResourceEndpointOrDefault(param: nil),
            .alternative1)
        XCTAssertEqual(
            KlarnaParamMapper.getResourceEndpointOrDefault(param: "garbage"),
            .alternative1)
        XCTAssertEqual(
            KlarnaParamMapper.getResourceEndpointOrDefault(param: "alternative_2"),
            .alternative2)
    }
}
