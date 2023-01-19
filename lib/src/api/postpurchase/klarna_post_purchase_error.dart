class KlarnaPostPurchaseError {
  final String name;
  final String message;
  final String? status;
  final bool isFatal;

  KlarnaPostPurchaseError(this.name, this.message, this.status, this.isFatal);
}
