// Pigeon schema for Klarna Network core.
// Regenerate: dart run pigeon --input pigeons/kn_core.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut:
        'ios/klarna_network_core/Sources/klarna_network_core/Messages.g.swift',
    kotlinOut:
        'android/src/main/kotlin/com/klarna/mobile/sdk/klarna_network_core/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.klarna.mobile.sdk.klarna_network_core',
    ),
    dartPackageName: 'klarna_network_core',
  ),
)
class KnAcquiringConfig {
  KnAcquiringConfig({
    required this.paymentAccountReference,
    required this.paymentAcquiringAccountId,
  });

  String paymentAccountReference;
  String paymentAcquiringAccountId;
}

class KnConfiguration {
  KnConfiguration({
    required this.clientId,
    required this.appReturnUrl,
    this.accountId,
    this.locale,
    this.klarnaNetworkSessionToken,
    this.acquiringConfig,
  });

  String clientId;
  String appReturnUrl;
  String? accountId;
  String? locale;
  String? klarnaNetworkSessionToken;
  KnAcquiringConfig? acquiringConfig;
}

class KnIntegrationMetadata {
  KnIntegrationMetadata({required this.integrator, this.originators});

  KnIntegratorMetadata integrator;
  List<KnOriginatorMetadata>? originators;
}

class KnIntegratorMetadata {
  KnIntegratorMetadata({
    required this.name,
    required this.sessionReference,
    this.moduleName,
    this.moduleVersion,
  });

  String name;
  String sessionReference;
  String? moduleName;
  String? moduleVersion;
}

class KnOriginatorMetadata {
  KnOriginatorMetadata({
    required this.name,
    required this.sessionReference,
    this.moduleName,
    this.moduleVersion,
  });

  String name;
  String sessionReference;
  String? moduleName;
  String? moduleVersion;
}

@HostApi()
abstract class KnCoreHostApi {
  @async
  void initialize(String instanceId, KnConfiguration configuration);

  @async
  String getSessionToken(String instanceId);

  @async
  void clearSession(String instanceId);

  void setIntegrationMetadata(
    String instanceId,
    KnIntegrationMetadata metadata,
  );

  @async
  bool handleReturnUrl(String url);

  void dispose(String instanceId);
}
