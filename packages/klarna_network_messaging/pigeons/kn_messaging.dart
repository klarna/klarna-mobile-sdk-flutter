// Pigeon schema for Klarna Network Messaging.
// Regenerate: dart run pigeon --input pigeons/kn_messaging.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut:
        'ios/klarna_network_messaging/Sources/klarna_network_messaging/Messages.g.swift',
    kotlinOut:
        'android/src/main/kotlin/com/klarna/mobile/sdk/klarna_network_messaging/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.klarna.mobile.sdk.klarna_network_messaging',
    ),
    dartPackageName: 'klarna_network_messaging',
  ),
)
enum KnPrequalificationStatus { approved, aborted }

/// Input for `klarna.messaging.prequalification.initiate`.
class KnPrequalificationData {
  KnPrequalificationData({required this.amount, required this.currency});

  int amount;
  String currency;
}

/// Transport type for the native prequalification result. The public Dart API
/// maps it to a sealed hierarchy. `expiresAtMillis` (epoch milliseconds, UTC)
/// is only set when `status` is `approved`.
class KnPrequalificationResult {
  KnPrequalificationResult({required this.status, this.expiresAtMillis});

  KnPrequalificationStatus status;
  int? expiresAtMillis;
}

@FlutterApi()
abstract class KnMessagingFlutterApi {
  void onResized(int viewId, double height);
}

@HostApi()
abstract class KnMessagingHostApi {
  @async
  KnPrequalificationResult prequalificationInitiate(
    String instanceId,
    KnPrequalificationData data,
  );
}
