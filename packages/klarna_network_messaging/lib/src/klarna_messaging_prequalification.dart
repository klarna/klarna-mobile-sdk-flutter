import 'package:flutter/foundation.dart' show internal, visibleForTesting;
import 'package:flutter/services.dart';
import 'package:klarna_network_core/klarna_network_core.dart';

import 'klarna_messaging_error.dart';
import 'messages.g.dart';

/// Input for [KlarnaMessagingPrequalification.initiate].
final class KlarnaMessagingPrequalificationData {
  /// Creates the prequalification input.
  const KlarnaMessagingPrequalificationData({
    required this.amount,
    required this.currency,
  });

  /// Purchase amount in minor units (for example `9999` for 99.99). Must be
  /// greater than zero.
  final int amount;

  /// ISO 4217 currency code (for example `USD`). Must not be empty.
  final String currency;

  @override
  bool operator ==(Object other) =>
      other is KlarnaMessagingPrequalificationData &&
      other.amount == amount &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() =>
      'KlarnaMessagingPrequalificationData(amount: $amount, currency: $currency)';
}

/// Outcome of a prequalification flow that was presented to the customer.
///
/// Every customer outcome is a success: approved, not prequalified, or
/// closed/abandoned. Only a flow that could not start throws a
/// [KlarnaSDKError].
sealed class KlarnaMessagingPrequalificationResult {
  const KlarnaMessagingPrequalificationResult();
}

/// The customer was prequalified.
final class KlarnaMessagingPrequalificationApproved
    extends KlarnaMessagingPrequalificationResult {
  /// Creates an approved result.
  const KlarnaMessagingPrequalificationApproved({required this.expiresAt});

  /// When the prequalification expires (UTC).
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      other is KlarnaMessagingPrequalificationApproved &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => expiresAt.hashCode;

  @override
  String toString() =>
      'KlarnaMessagingPrequalificationApproved(expiresAt: $expiresAt)';
}

/// The flow ended without a prequalification: the customer was not
/// prequalified or dismissed the flow.
final class KlarnaMessagingPrequalificationAborted
    extends KlarnaMessagingPrequalificationResult {
  /// Creates an aborted result.
  const KlarnaMessagingPrequalificationAborted();

  @override
  bool operator ==(Object other) =>
      other is KlarnaMessagingPrequalificationAborted;

  @override
  int get hashCode => (KlarnaMessagingPrequalificationAborted).hashCode;

  @override
  String toString() => 'KlarnaMessagingPrequalificationAborted()';
}

/// Maps the Pigeon transport [KnPrequalificationResult] to the public sealed
/// result hierarchy.
@visibleForTesting
KlarnaMessagingPrequalificationResult prequalificationResultFromTransport(
  KnPrequalificationResult result,
) {
  switch (result.status) {
    case KnPrequalificationStatus.approved:
      final millis = result.expiresAtMillis;
      if (millis == null) {
        throw StateError(
          'Approved prequalification result is missing expiresAtMillis.',
        );
      }
      return KlarnaMessagingPrequalificationApproved(
        expiresAt: DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
      );
    case KnPrequalificationStatus.aborted:
      return const KlarnaMessagingPrequalificationAborted();
  }
}

/// Klarna Network prequalification, reached through
/// `klarna.messaging.prequalification`.
///
/// Messaging placements are the recommended surface for presenting Klarna
/// messaging. Use [initiate] when a placement cannot be rendered. On Android
/// the app must have a foreground Activity.
class KlarnaMessagingPrequalification {
  KlarnaMessagingPrequalification._(this._api, this._instanceId);

  final KnMessagingHostApi _api;
  final String _instanceId;

  /// Starts the prequalification flow and completes when it ends.
  ///
  /// Throws an [ArgumentError] when `data.amount` is not greater than zero or
  /// `data.currency` is empty. Throws a [KlarnaSDKError] (for example
  /// `OPERATION_FAILED` or `INITIATE_ALREADY_IN_PROGRESS`) when the flow could
  /// not be started.
  Future<KlarnaMessagingPrequalificationResult> initiate(
    KlarnaMessagingPrequalificationData data,
  ) async {
    if (data.amount <= 0) {
      throw ArgumentError.value(
        data.amount,
        'data.amount',
        'must be greater than 0',
      );
    }
    if (data.currency.trim().isEmpty) {
      throw ArgumentError.value(data.currency, 'data.currency', 'is empty');
    }
    try {
      final result = await _api.prequalificationInitiate(
        _instanceId,
        KnPrequalificationData(amount: data.amount, currency: data.currency),
      );
      return prequalificationResultFromTransport(result);
    } on PlatformException catch (error) {
      throw klarnaSDKErrorFromPlatformException(error);
    }
  }
}

/// Klarna Network messaging features for a single [Klarna] instance. Obtain it
/// via `klarna.messaging`; it is not constructible directly.
class KlarnaMessaging {
  KlarnaMessaging._(this.instanceId) : _api = KnMessagingHostApi();

  /// Test-only constructor injecting an explicit id. Not part of the public
  /// contract.
  @visibleForTesting
  factory KlarnaMessaging.test({required String instanceId}) =>
      KlarnaMessaging._(instanceId);

  final KnMessagingHostApi _api;

  /// Identifies the bound network instance for internal routing.
  @internal
  final String instanceId;

  /// Prequalification flow. Use when a messaging placement cannot be rendered.
  late final KlarnaMessagingPrequalification prequalification =
      KlarnaMessagingPrequalification._(_api, instanceId);
}

/// Caches one [KlarnaMessaging] per [Klarna] so repeated `klarna.messaging`
/// returns the same object. `Expando` is weak, so the messaging object is
/// collected with its `Klarna`.
final Expando<KlarnaMessaging> _messagingCache = Expando<KlarnaMessaging>();

/// Adds `messaging` to an initialized [Klarna], so the messaging API is only
/// reachable from a real instance: `klarna.messaging.prequalification`.
extension KlarnaNetworkMessagingX on Klarna {
  /// The messaging feature for this instance.
  KlarnaMessaging get messaging =>
      _messagingCache[this] ??= KlarnaMessaging._(_id(this));
}

// instanceId is @internal; this sibling package is a sanctioned consumer.
// ignore: invalid_use_of_internal_member
String _id(Klarna klarna) => klarna.instanceId;
