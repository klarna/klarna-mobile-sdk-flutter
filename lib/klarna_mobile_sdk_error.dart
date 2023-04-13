class KlarnaMobileSDKError {
  final String name;
  final String message;
  final String? status;
  final bool isFatal;

  KlarnaMobileSDKError(
      this.name, this.message, this.status, this.isFatal);
}
