import 'package:flutter/foundation.dart';

import 'messages.g.dart';

/// Routes native payment button events to per-view callbacks.
class KlarnaPaymentEventDispatcher implements KnPaymentFlutterApi {
  KlarnaPaymentEventDispatcher._() {
    KnPaymentFlutterApi.setUp(this);
  }

  static final KlarnaPaymentEventDispatcher instance =
      KlarnaPaymentEventDispatcher._();

  // Keyed by per-button view id (not instanceId) so each button — even several
  // on the same instance — gets its own press callback.
  final Map<int, VoidCallback> _onPressed = {};

  /// Registers a press callback for the button [viewId].
  void registerButtonPressed(int viewId, VoidCallback onPressed) =>
      _onPressed[viewId] = onPressed;

  /// Removes the press callback for the button [viewId].
  void unregisterButtonPressed(int viewId) => _onPressed.remove(viewId);

  @override
  void onButtonPressed(int viewId) => _onPressed[viewId]?.call();
}
