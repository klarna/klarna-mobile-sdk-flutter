/// Klarna Network core for Flutter.
///
/// Creates and holds the native `Klarna` instance (keyed by [Klarna.instanceId])
/// that the Klarna Network feature packages bind to. Wraps the Pigeon-generated
/// host API with a top-level [Klarna] and a nested [KlarnaNetwork] /
/// [KlarnaNetworkSession].
library;

import 'dart:math';

import 'package:flutter/foundation.dart' show internal, visibleForTesting;

import 'src/messages.g.dart';

// The public data types follow the native Klarna API spec naming (`Klarna*`).
// They alias the Pigeon-generated transport types, which keep an internal `Kn`
// prefix so they don't collide with the native SDK's own `Klarna*` types in the
// Swift/Kotlin plugin code.
typedef KlarnaAcquiringConfig = KnAcquiringConfig;
typedef KlarnaConfiguration = KnConfiguration;
typedef KlarnaIntegrationMetadata = KnIntegrationMetadata;
typedef KlarnaIntegratorMetadata = KnIntegratorMetadata;
typedef KlarnaOriginatorMetadata = KnOriginatorMetadata;

/// A configured Klarna instance — the entry point to Klarna Network features.
///
/// Call [Klarna.initialize] to create one, then pass its [instanceId] to a
/// Klarna Network feature package to bind it to this Klarna session, or use
/// [network] to reach the session APIs.
class Klarna {
  Klarna._(this._api, this.instanceId)
      : network = KlarnaNetwork._(_api, instanceId);

  final KnCoreHostApi _api;
  KlarnaIntegrationMetadata? _integrationMetadata;

  /// Instances keyed by their configuration, so repeated [initialize] calls
  /// with the same [KlarnaConfiguration] reuse a single native session instead
  /// of spinning up a duplicate.
  static final Map<String, Klarna> _cache = <String, Klarna>{};

  /// Identifies this Klarna instance to the native layer and sibling packages.
  ///
  /// Marked [internal] so it stays readable by sibling Klarna Network feature
  /// packages (e.g. `klarna_network_payment`) that bind to the same native
  /// instance, while the analyzer flags any use from outside these packages —
  /// merchants don't need to read it directly. (Dart equivalent of the native
  /// `@_spi` / `@RestrictTo` gating on the instance store.)
  @internal
  final String instanceId;

  /// Klarna Network APIs scoped to this instance (e.g. [KlarnaNetwork.session]).
  final KlarnaNetwork network;

  /// Create and initialize a Klarna instance.
  ///
  /// Calling this twice with an equivalent [configuration] returns the same
  /// instance, backed by a single native session. [dispose] evicts the
  /// instance so a later [initialize] re-creates it.
  static Future<Klarna> initialize(KlarnaConfiguration configuration) async {
    final key = _cacheKey(configuration);
    final cached = _cache[key];
    if (cached != null) return cached;
    final klarna = await _create(configuration, _newInstanceId());
    _cache[key] = klarna;
    return klarna;
  }

  /// Test-only seam: initialize with an explicit [instanceId], bypassing the
  /// configuration cache. Not part of the public contract — the merchant-facing
  /// [initialize] takes only a [KlarnaConfiguration] (matching the spec and the
  /// native SDK).
  @visibleForTesting
  static Future<Klarna> initializeWithInstanceId(
    KlarnaConfiguration configuration,
    String instanceId,
  ) =>
      _create(configuration, instanceId);

  static Future<Klarna> _create(
    KlarnaConfiguration configuration,
    String id,
  ) async {
    final api = KnCoreHostApi();
    await api.initialize(id, configuration);
    return Klarna._(api, id);
  }

  /// Clears the configuration cache. For tests that reuse configurations across
  /// cases and need each [initialize] to hit the native layer afresh.
  @visibleForTesting
  static void clearInstanceCache() => _cache.clear();

  /// Cache key over the configuration fields.
  static String _cacheKey(KlarnaConfiguration c) => <String>[
        c.clientId,
        c.appReturnUrl,
        c.accountId ?? '',
        c.locale ?? '',
        c.klarnaNetworkSessionToken ?? '',
        c.acquiringConfig?.paymentAccountReference ?? '',
        c.acquiringConfig?.paymentAcquiringAccountId ?? '',
      ].join('|');

  /// Last integration metadata set on this instance, if any.
  KlarnaIntegrationMetadata? get integrationMetadata => _integrationMetadata;

  /// Attach integration metadata to this Klarna instance.
  void setIntegrationMetadata(KlarnaIntegrationMetadata metadata) {
    _integrationMetadata = metadata;
    _api.setIntegrationMetadata(instanceId, metadata);
  }

  /// Release this instance and its native resources. Also evicts it from the
  /// configuration cache so a later [initialize] with the same configuration
  /// creates a fresh instance.
  Future<void> dispose() {
    _cache.removeWhere((_, klarna) => identical(klarna, this));
    return _api.dispose(instanceId);
  }

  /// Handle a return URL (deep link) routed back into the app. Static because
  /// the native layer dispatches it to whichever instance owns the flow.
  static Future<bool> handleReturnUrl(String url) =>
      KnCoreHostApi().handleReturnUrl(url);

  static final Random _random = Random.secure();

  static String _newInstanceId() =>
      'kn_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}';
}

/// Klarna Network APIs for a single [Klarna] instance.
class KlarnaNetwork {
  KlarnaNetwork._(KnCoreHostApi api, String instanceId)
      : session = KlarnaNetworkSession._(api, instanceId);

  /// Session APIs (token retrieval, clearing).
  final KlarnaNetworkSession session;
}

/// The Klarna Network session for a single [Klarna] instance.
class KlarnaNetworkSession {
  KlarnaNetworkSession._(this._api, this._instanceId);

  final KnCoreHostApi _api;
  final String _instanceId;

  /// Fetch a Klarna Network session token.
  Future<String> token() => _api.getSessionToken(_instanceId);

  /// Clear the current session.
  Future<void> clear() => _api.clearSession(_instanceId);
}
