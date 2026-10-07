import 'package:flutter/foundation.dart' show internal;
import 'package:klarna_network_core/klarna_network_core.dart';

/// Configuration describing a Klarna messaging placement to render.
final class KlarnaMessagingPlacementConfiguration {
  /// Creates a configuration for an auto-sizing credit promotion placement.
  const KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize({
    required this.amount,
    required this.currency,
    this.theme,
  }) : placementWireKind = 'CreditPromotionAutoSize';

  /// Creates a configuration for a credit promotion badge placement.
  const KlarnaMessagingPlacementConfiguration.creditPromotionBadge({
    required this.amount,
    required this.currency,
    this.theme,
  }) : placementWireKind = 'CreditPromotionBadge';

  /// Purchase amount in minor units.
  final int amount;

  /// ISO 4217 currency code for [amount].
  final String currency;

  final KlarnaTheme? theme;

  @internal
  final String placementWireKind;

  @override
  bool operator ==(Object other) =>
      other is KlarnaMessagingPlacementConfiguration &&
      other.placementWireKind == placementWireKind &&
      other.amount == amount &&
      other.currency == currency &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(placementWireKind, amount, currency, theme);
}
