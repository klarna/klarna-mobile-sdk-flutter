class KlarnaResult {
  final String data;
  final String error;

  KlarnaResult(this.data, this.error);

  factory KlarnaResult.fromJson(Map<String, dynamic> json) {
    return KlarnaResult(json['data'], json['error']);
  }

  @override
  String toString() {
    return '{data: "$data", error: "$error"}';
  }
}
