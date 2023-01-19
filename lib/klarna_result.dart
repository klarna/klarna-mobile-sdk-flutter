import 'dart:convert';

class KlarnaResult {
  final String? data;
  final String? error;

  KlarnaResult(this.data, this.error);

  factory KlarnaResult.fromJson(Map<String, dynamic> jsonMap) {
    return KlarnaResult(jsonMap['data'], jsonMap['error']);
  }

  factory KlarnaResult.fromJsonString(String? jsonString) {
    if (jsonString != null) {
      return KlarnaResult.fromJson(json.decode(jsonString));
    } else {
      return KlarnaResult(null, null);
    }
  }

  @override
  String toString() {
    return '{data: "$data", error: "$error"}';
  }
}
