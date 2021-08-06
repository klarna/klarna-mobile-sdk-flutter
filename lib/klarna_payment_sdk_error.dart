class KlarnaPaymentSDKError {
  final String message;
  final String action;
  final String name;
  final bool isFatal;
  final List<String> invalidFields;

  const KlarnaPaymentSDKError(
      {this.message, this.action, this.name, this.invalidFields, this.isFatal});

  @override
  String toString() {
    return "message: $message, action: $action, name: $name, isFatal: $isFatal, invalidFields: $invalidFields";
  }
}
