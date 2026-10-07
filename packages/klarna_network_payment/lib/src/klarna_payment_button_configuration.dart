import 'package:flutter/foundation.dart' show internal;
import 'package:klarna_network_core/klarna_network_core.dart';

enum KlarnaPaymentButtonIntent {
  pay('pay'),
  subscribe('subscribe'),
  addToWallet('addToWallet');

  const KlarnaPaymentButtonIntent(this.wireValue);

  @internal
  final String wireValue;
}

/// Configuration for the appearance and intent of a Klarna payment button.
class KlarnaPaymentButtonConfiguration {
  const KlarnaPaymentButtonConfiguration({
    this.state,
    this.intent,
    this.shape,
    this.style,
    this.theme,
  });

  final KlarnaButtonState? state;
  final KlarnaPaymentButtonIntent? intent;
  final KlarnaButtonShape? shape;
  final KlarnaButtonStyle? style;
  final KlarnaTheme? theme;

  @override
  bool operator ==(Object other) =>
      other is KlarnaPaymentButtonConfiguration &&
      other.state == state &&
      other.intent == intent &&
      other.shape == shape &&
      other.style == style &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(state, intent, shape, style, theme);
}
