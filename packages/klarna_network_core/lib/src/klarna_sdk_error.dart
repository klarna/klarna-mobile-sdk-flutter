/// An error surfaced by the Klarna SDK.
class KlarnaSDKError implements Exception {
  const KlarnaSDKError({
    required this.name,
    required this.message,
    this.cause,
  });

  final String name;

  final String message;

  final Object? cause;

  @override
  String toString() => 'KlarnaSDKError($name, $message)';
}
