import 'package:flutter/foundation.dart' show internal;

/// Corner shape for Klarna buttons.
enum KlarnaButtonShape {
  roundedRect('roundedRect'),
  pill('pill'),
  rectangle('rectangle');

  const KlarnaButtonShape(this.wireValue);

  @internal
  final String wireValue;
}

/// Fill style for Klarna buttons.
enum KlarnaButtonStyle {
  filled('filled'),
  outlined('outlined');

  const KlarnaButtonStyle(this.wireValue);

  @internal
  final String wireValue;
}

/// Visual state for Klarna buttons.
enum KlarnaButtonState {
  default_('default'),
  disabled('disabled'),
  loading('loading');

  const KlarnaButtonState(this.wireValue);

  @internal
  final String wireValue;
}
