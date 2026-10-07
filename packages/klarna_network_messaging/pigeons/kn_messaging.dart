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
@FlutterApi()
abstract class KnMessagingFlutterApi {
  void onResized(int viewId, double height);
}
