import 'package:flutter/foundation.dart' show internal;

/// Shared color theme for Klarna Flutter UI components.
enum KlarnaTheme {
  light('light'),
  dark('dark'),
  automatic('automatic');

  const KlarnaTheme(this.wireValue);

  @internal
  final String wireValue;
}
