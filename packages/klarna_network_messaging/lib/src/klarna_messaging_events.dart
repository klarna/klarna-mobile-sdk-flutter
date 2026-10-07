import 'package:flutter/foundation.dart';

import 'messages.g.dart';

/// Routes native messaging placement events to per-view callbacks.
class KlarnaMessagingEventDispatcher implements KnMessagingFlutterApi {
  KlarnaMessagingEventDispatcher._() {
    KnMessagingFlutterApi.setUp(this);
  }

  /// The shared dispatcher instance.
  static final KlarnaMessagingEventDispatcher instance =
      KlarnaMessagingEventDispatcher._();

  final Map<int, ValueChanged<double>> _onResized = {};

  /// Registers a resize callback for [viewId].
  void registerResized(int viewId, ValueChanged<double> onResized) =>
      _onResized[viewId] = onResized;

  /// Removes all callbacks registered for [viewId].
  void unregister(int viewId) => _onResized.remove(viewId);

  @override
  void onResized(int viewId, double height) => _onResized[viewId]?.call(height);
}
