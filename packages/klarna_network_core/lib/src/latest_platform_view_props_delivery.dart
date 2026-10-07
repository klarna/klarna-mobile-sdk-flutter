import 'dart:async';

import 'package:flutter/foundation.dart';

/// Delivers only the latest platform-view props once a sink is attached.
@internal
final class LatestPlatformViewPropsDelivery {
  LatestPlatformViewPropsDelivery({
    required void Function(Object error, StackTrace stackTrace) onError,
  }) : _onError = onError;

  final void Function(Object error, StackTrace stackTrace) _onError;

  Future<void> Function(Map<String, Object?> props)? _send;
  Map<String, Object?>? _pending;
  bool _disposed = false;

  /// Queues [props] for delivery, replacing any pending update.
  void update(Map<String, Object?> props) {
    if (_disposed) return;

    final snapshot = Map<String, Object?>.unmodifiable(props);
    final send = _send;
    if (send == null) {
      _pending = snapshot;
      return;
    }
    _dispatch(send, snapshot);
  }

  /// Attaches the [send] sink and flushes any pending props.
  void attach(
    Future<void> Function(Map<String, Object?> props) send,
  ) {
    if (_disposed) return;
    _send = send;

    final pending = _pending;
    _pending = null;
    if (pending != null) _dispatch(send, pending);
  }

  void dispose() {
    _disposed = true;
    _pending = null;
    _send = null;
  }

  void _dispatch(
    Future<void> Function(Map<String, Object?> props) send,
    Map<String, Object?> props,
  ) {
    try {
      unawaited(send(props).then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          _onError(error, stackTrace);
        },
      ));
    } catch (error, stackTrace) {
      _onError(error, stackTrace);
    }
  }
}
