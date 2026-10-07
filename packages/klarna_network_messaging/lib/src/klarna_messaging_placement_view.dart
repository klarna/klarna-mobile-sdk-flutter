import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:flutter/services.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
// ignore: implementation_imports
import 'package:klarna_network_core/src/latest_platform_view_props_delivery.dart';

import 'klarna_messaging_configuration.dart';
import 'klarna_messaging_events.dart';
import 'klarna_messaging_height.dart';

const String _kViewType = 'com.klarna.mobile.sdk/messaging_placement';

const double _kMinHeightFallback = 60;

// ignore: invalid_use_of_internal_member
String _idOf(Klarna klarna) => klarna.instanceId;

/// A widget that renders a Klarna messaging placement.
class KlarnaMessagingPlacementView extends StatefulWidget {
  /// Creates a [KlarnaMessagingPlacementView].
  const KlarnaMessagingPlacementView({
    super.key,
    required this.instance,
    required this.configuration,
  });

  final Klarna instance;

  final KlarnaMessagingPlacementConfiguration configuration;

  @override
  State<KlarnaMessagingPlacementView> createState() =>
      _KlarnaMessagingPlacementViewState();
}

class _KlarnaMessagingPlacementViewState
    extends State<KlarnaMessagingPlacementView> {
  static int _nextViewId = 0;

  late final int _viewId = _nextViewId++;
  // ignore: invalid_use_of_internal_member
  late final LatestPlatformViewPropsDelivery _propsDelivery;

  double _nativeViewHeight = 0;
  bool _hasReceivedResize = false;

  @override
  void initState() {
    super.initState();
    _propsDelivery = LatestPlatformViewPropsDelivery(
      onError: (error, stackTrace) {
        debugPrint('KlarnaMessagingPlacementView prop update failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
    _registerCallbacks();
  }

  @override
  void didUpdateWidget(KlarnaMessagingPlacementView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registerCallbacks();
    if (_idOf(oldWidget.instance) != _idOf(widget.instance) ||
        oldWidget.configuration != widget.configuration) {
      _nativeViewHeight = 0;
      _hasReceivedResize = false;
      _propsDelivery.update(_props);
    }
  }

  void _registerCallbacks() {
    final dispatcher = KlarnaMessagingEventDispatcher.instance;
    dispatcher.registerResized(_viewId, _onResized);
  }

  @override
  void dispose() {
    KlarnaMessagingEventDispatcher.instance.unregister(_viewId);
    _propsDelivery.dispose();
    super.dispose();
  }

  void _onResized(double rawHeight) {
    final next = nextHeightOnResize(
      rawHeight: rawHeight,
      prevHeight: _nativeViewHeight,
      hasError: false,
      isFirstResize: !_hasReceivedResize,
    );
    if (next != null && mounted) {
      setState(() {
        _nativeViewHeight = next;
        _hasReceivedResize = true;
      });
    }
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('$_kViewType/$_viewId');
    _propsDelivery.attach(
      (props) => channel.invokeMethod<void>('setProps', props),
    );
  }

  Map<String, Object?> get _props => <String, Object?>{
        'instanceId': _idOf(widget.instance),
        // ignore: invalid_use_of_internal_member
        'placementType': widget.configuration.placementWireKind,
        'amount': widget.configuration.amount.toString(),
        'currency': widget.configuration.currency,
        // ignore: invalid_use_of_internal_member
        'theme': widget.configuration.theme?.wireValue ?? '',
      };

  Map<String, Object?> get _creationParams => <String, Object?>{
        'viewId': _viewId,
        ..._props,
      };

  double get _resolvedHeight {
    if (_nativeViewHeight > 0) {
      return _nativeViewHeight;
    }
    return _hasReceivedResize ? 0 : _kMinHeightFallback;
  }

  @override
  Widget build(BuildContext context) {
    final Widget platformView;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        platformView = PlatformViewLink(
          viewType: _kViewType,
          surfaceFactory: (context, controller) => AndroidViewSurface(
            controller: controller as AndroidViewController,
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          ),
          onCreatePlatformView: (params) {
            // Force Hybrid Composition: under texture composition native animation
            // can freeze while Flutter is idle (flutter/flutter#122027).
            final controller = PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: _kViewType,
              layoutDirection: Directionality.of(context),
              creationParams: _creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            );
            controller.addOnPlatformViewCreatedListener((id) {
              params.onPlatformViewCreated(id);
              _onPlatformViewCreated(id);
            });
            controller.create();
            return controller;
          },
        );
      case TargetPlatform.iOS:
        platformView = UiKitView(
          viewType: _kViewType,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
        );
      default:
        return ErrorWidget(
          'KlarnaMessagingPlacementView is not supported on '
          '$defaultTargetPlatform',
        );
    }
    return SizedBox(
      width: double.infinity,
      height: _resolvedHeight,
      child: ClipRect(child: platformView),
    );
  }
}
