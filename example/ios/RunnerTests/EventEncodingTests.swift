import XCTest
@testable import klarna_mobile_sdk_flutter

/// Verifies the JSON shape of the listener events and error wrapper that are
/// encoded and sent to the Dart side over the event channel. The Dart code
/// decodes these exact field names and `name` discriminators.
class EventEncodingTests: XCTestCase {

    private func encodeToObject<T: Encodable>(_ value: T) throws
        -> [String: Any]
    {
        let data = try JSONEncoder().encode(value)
        let object = try JSONSerialization.jsonObject(with: data)
        return try XCTUnwrap(object as? [String: Any])
    }

    func testOnInitializedShape() throws {
        let event = KlarnaPostPurchaseSDKListenerEvents.OnInitialized(id: 5)
        let json = try encodeToObject(event)
        XCTAssertEqual(json["id"] as? Int, 5)
        XCTAssertEqual(json["name"] as? String, "onInitialized")
    }

    func testOnAuthorizeRequestedShape() throws {
        let event =
            KlarnaPostPurchaseSDKListenerEvents.OnAuthorizeRequested(id: 6)
        let json = try encodeToObject(event)
        XCTAssertEqual(json["id"] as? Int, 6)
        XCTAssertEqual(json["name"] as? String, "onAuthorizeRequested")
    }

    func testOnRenderedOperationShape() throws {
        let event = KlarnaPostPurchaseSDKListenerEvents.OnRenderedOperation(
            id: 7, renderResult: "STATE_CHANGE")
        let json = try encodeToObject(event)
        XCTAssertEqual(json["id"] as? Int, 7)
        XCTAssertEqual(json["name"] as? String, "onRenderedOperation")
        XCTAssertEqual(json["renderResult"] as? String, "STATE_CHANGE")
    }

    func testOnErrorShapeWithNestedError() throws {
        let wrapper = KlarnaPostPurchaseErrorWrapper(
            name: "NetworkError",
            message: "timed out",
            isFatal: true,
            status: "504")
        let event = KlarnaPostPurchaseSDKListenerEvents.OnError(
            id: 8, error: wrapper)

        let json = try encodeToObject(event)
        XCTAssertEqual(json["id"] as? Int, 8)
        XCTAssertEqual(json["name"] as? String, "onError")

        let error = try XCTUnwrap(json["error"] as? [String: Any])
        XCTAssertEqual(error["name"] as? String, "NetworkError")
        XCTAssertEqual(error["message"] as? String, "timed out")
        XCTAssertEqual(error["isFatal"] as? Bool, true)
        XCTAssertEqual(error["status"] as? String, "504")
    }

    func testErrorWrapperAllowsNilStatus() throws {
        let wrapper = KlarnaPostPurchaseErrorWrapper(
            name: "E", message: "m", isFatal: false, status: nil)
        let json = try encodeToObject(wrapper)
        XCTAssertEqual(json["name"] as? String, "E")
        XCTAssertEqual(json["isFatal"] as? Bool, false)
        // A nil status is either absent or NSNull, never a string.
        XCTAssertNil(json["status"] as? String)
    }

    func testResultErrorRawValues() {
        XCTAssertEqual(ResultError.unknownError.rawValue, "UnknownError")
        XCTAssertEqual(
            ResultError.pluginMethodError.rawValue,
            "KlarnaFlutterPluginMethodError")
        XCTAssertEqual(
            ResultError.klarnaPostPurchaseSDKError.rawValue,
            "KlarnaPostPurchaseSDKError")
    }
}
