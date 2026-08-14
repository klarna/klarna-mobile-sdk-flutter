// Pigeon schema for Klarna Network core.
//
// Creates and stores the native `Klarna` instance (keyed by instanceId) that
// Klarna Network feature packages fetch via the native instance store.
//
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

/// Acquiring configuration for card-on-file / acquiring flows.
class KnAcquiringConfig {
  KnAcquiringConfig({
    required this.paymentAccountReference,
    required this.paymentAcquiringAccountId,
  });

  String paymentAccountReference;
  String paymentAcquiringAccountId;
}

/// Configuration for creating a Klarna instance.
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

/// Metadata identifying the Flutter integrator and optional originators.
class KnIntegrationMetadata {
  KnIntegrationMetadata({
    required this.integrator,
    this.originators,
  });

  KnIntegratorMetadata integrator;
  List<KnOriginatorMetadata>? originators;
}

/// Metadata for the top-level integration owner.
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

/// Metadata for an upstream module that originated the integration.
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
  /// Create and store a Klarna instance for [instanceId].
  @async
  void initialize(String instanceId, KnConfiguration configuration);

  /// Fetch a Klarna Network session token.
  @async
  String getSessionToken(String instanceId);

  /// Clear the current session.
  @async
  void clearSession(String instanceId);

  /// Attach integration metadata to an initialized Klarna instance.
  void setIntegrationMetadata(
      String instanceId, KnIntegrationMetadata metadata);

  /// Handle a return URL (deep link) routed back into the app.
  @async
  bool handleReturnUrl(String url);

  /// Release the instance.
  void dispose(String instanceId);
}
