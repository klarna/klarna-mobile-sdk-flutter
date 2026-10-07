/// Klarna Network core for Flutter. Creates and holds the native `Klarna`
/// instance (keyed by [Klarna.instanceId]) that feature packages bind to.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show internal, visibleForTesting;
import 'package:flutter/services.dart';

import 'src/klarna_sdk_error.dart';
import 'src/messages.g.dart';

export 'src/klarna_button_types.dart'
    show KlarnaButtonShape, KlarnaButtonState, KlarnaButtonStyle;
export 'src/klarna_sdk_error.dart' show KlarnaSDKError;
export 'src/klarna_theme.dart' show KlarnaTheme;

// Public `Klarna*` types alias the Pigeon `Kn*` transport types (the `Kn`
// prefix avoids colliding with the native SDK's `Klarna*` types).

/// Acquiring Partner configuration for a Klarna session.
typedef KlarnaAcquiringConfig = KnAcquiringConfig;

/// Configuration used to initialize a [Klarna] instance.
typedef KlarnaConfiguration = KnConfiguration;

/// Metadata describing the integration using the SDK.
typedef KlarnaIntegrationMetadata = KnIntegrationMetadata;

/// Metadata describing the integrator of the SDK.
typedef KlarnaIntegratorMetadata = KnIntegratorMetadata;

/// Metadata describing the originator of a session.
typedef KlarnaOriginatorMetadata = KnOriginatorMetadata;

Future<T> _mapSDKError<T>(Future<T> future) async {
  try {
    return await future;
  } on PlatformException catch (error) {
    throw KlarnaSDKError(
      name: error.code,
      message: error.message ?? error.code,
      cause: error.details,
    );
  }
}

/// A configured Klarna instance — entry point to Klarna Network features.
/// Create with [Klarna.initialize], then pass it to feature packages or use
/// [network].
class Klarna {
  Klarna._(this._api, this.instanceId, this._cacheKeyUsed)
      : network = KlarnaNetwork._(_api, instanceId);

  final KnCoreHostApi _api;
  KlarnaIntegrationMetadata? _integrationMetadata;

  /// Cache key this instance was created under, or `null` when created via
  /// [initializeWithInstanceId]. Used by [dispose] to evict the right entry.
  final String? _cacheKeyUsed;

  /// Instances keyed by config so repeated [initialize] calls reuse one native
  /// session; caches the in-flight [Future] so concurrent same-key calls don't race.
  static final Map<String, Future<Klarna>> _cache = <String, Future<Klarna>>{};

  /// Identifies this instance to the native layer and sibling packages. [internal]
  /// so siblings can bind while merchant use is flagged (like native `@_spi`).
  @internal
  final String instanceId;

  /// Klarna Network APIs scoped to this instance.
  final KlarnaNetwork network;

  /// Create and initialize a Klarna instance. Same [configuration] reuses one
  /// instance until [dispose].
  static Future<Klarna> initialize(KlarnaConfiguration configuration) {
    final key = _cacheKey(configuration);
    return _cache.putIfAbsent(key, () {
      final future = _create(configuration, _newInstanceId(), key);
      unawaited(
        future.then(
          (_) {},
          onError: (_) {
            // On failure, evict so the next initialize() retries. Identity-check
            // avoids clobbering an entry a dispose()/re-initialize() replaced.
            if (identical(_cache[key], future)) _cache.remove(key);
          },
        ),
      );
      return future;
    });
  }

  /// Test-only: initialize with an explicit [instanceId], bypassing the cache.
  @visibleForTesting
  static Future<Klarna> initializeWithInstanceId(
    KlarnaConfiguration configuration,
    String instanceId,
  ) =>
      _create(configuration, instanceId, null);

  static Future<Klarna> _create(
    KlarnaConfiguration configuration,
    String id,
    String? cacheKeyUsed,
  ) async {
    final api = KnCoreHostApi();
    await _mapSDKError(api.initialize(id, configuration));
    return Klarna._(api, id, cacheKeyUsed);
  }

  /// Test-only: clear the configuration cache.
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

  /// The integration metadata currently set on this instance, if any.
  KlarnaIntegrationMetadata? get integrationMetadata => _integrationMetadata;

  /// Sets the integration [metadata] for this instance.
  Future<void> setIntegrationMetadata(
    KlarnaIntegrationMetadata metadata,
  ) async {
    await _mapSDKError(_api.setIntegrationMetadata(instanceId, metadata));
    _integrationMetadata = metadata;
  }

  /// Release this instance and its native resources, and evict it from the
  /// cache so a later [initialize] re-creates it.
  Future<void> dispose() async {
    final key = _cacheKeyUsed;
    if (key != null && identical(await _cache[key], this)) {
      _cache.remove(key);
    }
    return _mapSDKError(_api.dispose(instanceId));
  }

  /// Handle a return URL (deep link). Static: native routes it to the owning
  /// instance.
  static Future<bool> handleReturnUrl(String url) =>
      _mapSDKError(KnCoreHostApi().handleReturnUrl(url));

  static final Random _random = Random.secure();

  static String _newInstanceId() =>
      'kn_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}';
}

/// Groups the Klarna Network features for a [Klarna] instance.
class KlarnaNetwork {
  KlarnaNetwork._(KnCoreHostApi api, String instanceId)
      : session = KlarnaNetworkSession._(api, instanceId);

  /// The Klarna Network session for this instance.
  final KlarnaNetworkSession session;
}

/// A Klarna Network session bound to a [Klarna] instance.
class KlarnaNetworkSession {
  KlarnaNetworkSession._(this._api, this._instanceId);

  final KnCoreHostApi _api;
  final String _instanceId;

  /// Returns the current session token.
  Future<String> token() => _mapSDKError(_api.getSessionToken(_instanceId));

  /// Clears the current session.
  Future<void> clear() => _mapSDKError(_api.clearSession(_instanceId));
}
