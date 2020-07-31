import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/klarna_hybrid_sdk.dart';

const channel = const MethodChannel('klarna_hybrid_sdk');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  channel.setMockMethodCallHandler((MethodCall call) async {
    if (call.arguments['returnUrl'].length > 0) {
      return null;
    }
    throw PlatformException(code: "KlarnaFlutterPluginMethodError", message: "initialize", details: "Argument returnUrl can not be null.");
  });

  test("initialize with valid return url", () async {
    var res = await KlarnaHybridSDK.initialize("returnUrl");
    expect(res, null);
  });

  test("initialize with invalid return url", () async {
    try {
      await KlarnaHybridSDK.initialize("");
      fail("should throw invalidUrl error");
    } catch (error) {
      expect(error.toString(), PlatformException(code: "KlarnaFlutterPluginMethodError", message: "initialize", details: "Argument returnUrl can not be null.").toString());
    }
  });
}
