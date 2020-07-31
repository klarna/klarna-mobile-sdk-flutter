import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/klarna_post_purchase_experience.dart';

const channel = const MethodChannel('klarna_post_purchase_experience');

var clientId;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  channel.setMockMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case "initialize":
        if (call.arguments["id"] == null) {
          throw methodException(call.method, "id");
        }
        if (call.arguments["locale"] != "testLocale") {
          throw methodException(call.method, "locale");
        }
        if (call.arguments["purchaseCountry"] != "testPurchaseCountry") {
          throw methodException(call.method, "purchaseCountry");
        }
        clientId = call.arguments["id"];
        return '{"data": null, "error": null}';
      case "destroy":
        if (call.arguments["id"] == null) {
          throw methodException(call.method, "id");
        }
        if (call.arguments["id"] != clientId) {
          throw PlatformException(code: "MatchingIdError", message: "destroy", details: "");
        }
        return null;
      case "renderOperation":
        if (call.arguments["id"] == null) {
          throw methodException(call.method, "id");
        }
        if (call.arguments["operationToken"] == null) {
          throw methodException(call.method, "id");
        }
        return '{"data": "${call.arguments}", "error": null}';
      case "authorizationRequest":
        if (call.arguments["id"] == null) {
          throw methodException(call.method, "id");
        }
        return '{"data": "${call.arguments}", "error": null}';
    }
    if (call.arguments['returnUrl'].length > 0) {
      return null;
    }
    throw PlatformException(code: "ERROR");
  });

  test("initialize with valid params", () async {
    var client = await KlarnaPostPurchaseExperience.init("testLocale", "testPurchaseCountry");
    expect(client, isA<KlarnaPostPurchaseExperience>());
  });

  test("initialize with invalid locale param", () async {
    try {
      await KlarnaPostPurchaseExperience.init("", "testPurchaseCountry");
      fail("should have thrown an error for invalid locale");
    } catch (error) {
      expect(error.toString(), methodException("initialize", "locale").toString());
    }
  });

  test("initialize with invalid purchaseCountry param", () async {
    try {
      await KlarnaPostPurchaseExperience.init("testLocale", "");
      fail("should have thrown an error for invalid purchaseCountry");
    } catch (error) {
      expect(error.toString(), methodException("initialize", "purchaseCountry").toString());
    }
  });

  test("initialize with full params", () async {
    var client = await KlarnaPostPurchaseExperience.init("testLocale", "testPurchaseCountry", design: "testDesign");
    expect(client, isA<KlarnaPostPurchaseExperience>());
  });

  test("destroy initialized client", () async {
    var client = await KlarnaPostPurchaseExperience.init("testLocale", "testPurchaseCountry");
    expect(await client.destroy(), isNull);
  });

  test("destroy before initializing client", () async {
    var client = new KlarnaPostPurchaseExperience();
    try {
      await client.destroy();
    } catch (error) {
      expect(error.toString(), PlatformException(code: "MatchingIdError", message: "destroy", details: "").toString());
    }
  });

  test("renderOperation with full params", () async {
    var client = await KlarnaPostPurchaseExperience.init("testLocale", "testPurchaseCountry");
    var result = await client.renderOperation("testOperationToken", locale: "testLocale");
    expect(result.data, "{id: $clientId, locale: testLocale, operationToken: testOperationToken}");
    expect(result.error, null);
  });

  test("authorizationRequest with full params", () async {
    var client = await KlarnaPostPurchaseExperience.init("testLocale", "testPurchaseCountry");
    var result = await client.authorizationRequest("testClientId", "testScope", "testRedirectUri", locale: "testLocale", state: "testState", loginHint: "testLoginHint", responseType: "testResponseType");
    expect(result.data, "{id: $clientId, locale: testLocale, clientId: testClientId, scope: testScope, redirectUri: testRedirectUri, state: testState, loginHint: testLoginHint, responseType: testResponseType}");
    expect(result.error, null);
  });
}

PlatformException methodException(String methodName, String paramName) {
  return PlatformException(
      code: "KlarnaFlutterPluginMethodError",
      message: methodName,
      details: "Argument $paramName can not be null.");
}
