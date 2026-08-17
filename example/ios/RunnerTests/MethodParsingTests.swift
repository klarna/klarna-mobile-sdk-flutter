import Flutter
import XCTest
@testable import klarna_mobile_sdk_flutter

/// Tests for the FlutterMethodCall extensions and the post-purchase method parser.
class MethodParsingTests: XCTestCase {

    // MARK: - FlutterMethodCall extension helpers

    func testArgumentReturnsTypedValue() {
        let call = FlutterMethodCall(
            methodName: "anything",
            arguments: ["enabled": true, "count": 3])

        let enabled: Bool? = call.argument(key: "enabled")
        let count: Int? = call.argument(key: "count")

        XCTAssertEqual(enabled, true)
        XCTAssertEqual(count, 3)
    }

    func testArgumentReturnsNilForMissingKey() {
        let call = FlutterMethodCall(methodName: "anything", arguments: [:])
        let value: String? = call.argument(key: "missing")
        XCTAssertNil(value)
    }

    func testRequireArgumentReturnsValueWhenPresent() throws {
        let call = FlutterMethodCall(
            methodName: "anything", arguments: ["id": 42])
        let id: Int = try call.requireArgument(key: "id")
        XCTAssertEqual(id, 42)
    }

    func testRequireArgumentThrowsWhenMissing() {
        let call = FlutterMethodCall(
            methodName: "anything", arguments: ["other": 1])
        XCTAssertThrowsError(
            try call.requireArgument(key: "id") as Int)
    }

    // MARK: - KlarnaPostPurchaseSDKMethods.Parser

    private let parser = KlarnaPostPurchaseSDKMethods.Parser()

    func testParseCreate() throws {
        let call = FlutterMethodCall(
            methodName: "create",
            arguments: [
                "id": 7,
                "returnURL": "app://return",
                "environment": "PLAYGROUND",
                "region": "EU",
                "resourceEndpoint": "ALTERNATIVE_1",
            ])

        let method = try parser.parse(call: call)
        let create = try XCTUnwrap(method as? KlarnaPostPurchaseSDKMethods.Create)
        XCTAssertEqual(create.id, 7)
        XCTAssertEqual(create.returnURL, "app://return")
        XCTAssertEqual(create.environment, "PLAYGROUND")
        XCTAssertEqual(create.region, "EU")
        XCTAssertEqual(create.resourceEndpoint, "ALTERNATIVE_1")
    }

    func testParseInitialize() throws {
        let call = FlutterMethodCall(
            methodName: "initialize",
            arguments: [
                "id": 1,
                "locale": "en-US",
                "purchaseCountry": "US",
                "design": "titanium",
            ])

        let method = try parser.parse(call: call)
        let initialize =
            try XCTUnwrap(method as? KlarnaPostPurchaseSDKMethods.Initialize)
        XCTAssertEqual(initialize.id, 1)
        XCTAssertEqual(initialize.locale, "en-US")
        XCTAssertEqual(initialize.purchaseCountry, "US")
        XCTAssertEqual(initialize.design, "titanium")
    }

    func testParseAuthorizationRequest() throws {
        let call = FlutterMethodCall(
            methodName: "authorizationRequest",
            arguments: [
                "id": 2,
                "clientId": "client",
                "scope": "scope",
                "redirectUri": "app://redirect",
                "locale": "sv-SE",
                "state": "state-value",
                "loginHint": "user@example.com",
                "responseType": "code",
            ])

        let method = try parser.parse(call: call)
        let request =
            try XCTUnwrap(method as? KlarnaPostPurchaseSDKMethods.AuthorizationRequest)
        XCTAssertEqual(request.clientId, "client")
        XCTAssertEqual(request.scope, "scope")
        XCTAssertEqual(request.redirectUri, "app://redirect")
        XCTAssertEqual(request.state, "state-value")
        XCTAssertEqual(request.responseType, "code")
    }

    func testParseRenderOperation() throws {
        let call = FlutterMethodCall(
            methodName: "renderOperation",
            arguments: ["id": 3, "operationToken": "token"])

        let method = try parser.parse(call: call)
        let render =
            try XCTUnwrap(method as? KlarnaPostPurchaseSDKMethods.RenderOperation)
        XCTAssertEqual(render.operationToken, "token")
        XCTAssertNil(render.locale)
    }

    func testParseDestroy() throws {
        let call = FlutterMethodCall(
            methodName: "destroy", arguments: ["id": 9])

        let method = try parser.parse(call: call)
        let destroy =
            try XCTUnwrap(method as? KlarnaPostPurchaseSDKMethods.Destroy)
        XCTAssertEqual(destroy.id, 9)
    }

    func testParseUnknownMethodReturnsNil() throws {
        let call = FlutterMethodCall(methodName: "noSuchMethod", arguments: [:])
        XCTAssertNil(try parser.parse(call: call))
    }

    func testParseDestroyWithoutIdThrows() {
        let call = FlutterMethodCall(methodName: "destroy", arguments: [:])
        XCTAssertThrowsError(try parser.parse(call: call))
    }
}
