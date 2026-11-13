import 'package:klarna_network_messaging/klarna_network_messaging.dart';

/// Renders a [KlarnaMessagingPrequalificationResult] as a readable string:
/// `Approved` with the UTC `expiresAt`, or `Aborted`.
String prequalificationResultToDisplayString(
  KlarnaMessagingPrequalificationResult result,
) =>
    switch (result) {
      KlarnaMessagingPrequalificationApproved(:final expiresAt) =>
        'Approved, expires ${expiresAt.toUtc().toIso8601String()}',
      KlarnaMessagingPrequalificationAborted() => 'Aborted',
    };

/// Renders an error thrown by `prequalification.initiate` as `name: message`.
/// A [KlarnaSDKError] keeps its native name (for example `OPERATION_FAILED`);
/// any other error is shown with its runtime type as the name.
String prequalificationErrorToDisplayString(Object error) {
  if (error is KlarnaSDKError) return '${error.name}: ${error.message}';
  return '${error.runtimeType}: $error';
}
