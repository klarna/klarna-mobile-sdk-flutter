import 'package:flutter_test/flutter_test.dart';

import '../lib/klarna_result.dart';


void main() {
  test("json parse with data and error", () async {
    var json = Map<String, dynamic>();
    json["data"] = "testData";
    json["error"] = "testError";
    var result = KlarnaResult.fromJson(json);
    expect(result.data, "testData");
    expect(result.error, "testError");
  });

  test("json parse with just data", () async {
    var json = Map<String, dynamic>();
    json["data"] = "testData";
    var result = KlarnaResult.fromJson(json);
    expect(result.data, "testData");
    expect(result.error, isNull);
  });

  test("json parse with just error", () async {
    var json = Map<String, dynamic>();
    json["error"] = "testError";
    var result = KlarnaResult.fromJson(json);
    expect(result.data, isNull);
    expect(result.error, "testError");
  });

  test("json parse without params", () async {
    var json = Map<String, dynamic>();
    var result = KlarnaResult.fromJson(json);
    expect(result.data, isNull);
    expect(result.error, isNull);
  });
}