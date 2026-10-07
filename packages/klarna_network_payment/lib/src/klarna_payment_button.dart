import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:flutter/services.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_core/src/latest_platform_view_props_delivery.dart';

import 'klarna_payment_button_configuration.dart';
import 'klarna_payment_events.dart';

// Sibling KN package is a sanctioned consumer of @internal wire values
// (KlarnaTheme / KlarnaButton* enums live in klarna_network_core).
// ignore_for_file: implementation_imports, invalid_use_of_internal_member

/// Native PlatformViewFactory view type.
const String _kViewType = 'com.klarna.mobile.sdk/payment_button';

String _instanceIdOf(Klarna instance) => instance.instanceId;

/// Min height the native button renders without clipping. Android enforces a
/// floor in `KlarnaButton.onMeasure`; 56 clears it at normal font scale.
const double _kMinHeight = 56;

/// Embeds the native Klarna Payment Button via a Platform View. Bound to a
/// Klarna instance by [instance]; [onPressed] fires on tap, routed by view id.
class KlarnaPaymentButton extends StatefulWidget {
  const KlarnaPaymentButton({
    super.key,
    required this.instance,
    required this.onPressed,
    this.configuration = const KlarnaPaymentButtonConfiguration(),
    this.state,
    this.height = _kMinHeight,
  });

  /// Binds this button to an initialized Klarna instance.
  final Klarna instance;

  final KlarnaPaymentButtonConfiguration configuration;
  final KlarnaButtonState? state;

  /// Fires when the native button is pressed.
  final VoidCallback onPressed;

  /// Target height, raised to the native button's minimum if below it.
  final double height;

  double get _effectiveHeight => height < _kMinHeight ? _kMinHeight : height;

  @override
  State<KlarnaPaymentButton> createState() => _KlarnaPaymentButtonState();
}

class _KlarnaPaymentButtonState extends State<KlarnaPaymentButton> {
  static int _nextViewId = 0;

  /// Unique per-widget view id, so press callbacks stay independent.
  late final int _viewId = _nextViewId++;

  late final LatestPlatformViewPropsDelivery _propsDelivery;

  @override
  void initState() {
    super.initState();
    _propsDelivery = LatestPlatformViewPropsDelivery(
      onError: (error, stackTrace) {
        debugPrint('KlarnaPaymentButton prop update failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
    _registerCallback();
  }

  @override
  void didUpdateWidget(KlarnaPaymentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registerCallback();
    if (_propsChanged(oldWidget)) {
      _propsDelivery.update(_props);
    }
  }

  bool _propsChanged(KlarnaPaymentButton old) =>
      old.state != widget.state ||
      old.configuration != widget.configuration ||
      // Compare clamped height: both flooring to the minimum need no update.
      old._effectiveHeight != widget._effectiveHeight ||
      _instanceIdOf(old.instance) != _instanceIdOf(widget.instance);

  void _registerCallback() {
    KlarnaPaymentEventDispatcher.instance.registerButtonPressed(
      _viewId,
      () => widget.onPressed(),
    );
  }

  @override
  void dispose() {
    KlarnaPaymentEventDispatcher.instance.unregisterButtonPressed(_viewId);
    _propsDelivery.dispose();
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('$_kViewType/$_viewId');
    _propsDelivery.attach(
      (props) => channel.invokeMethod<void>('setProps', props),
    );
  }

  Map<String, Object?> get _props => <String, Object?>{
        'instanceId': _instanceIdOf(widget.instance),
        // Android sizes to content, so send height explicitly; iOS ignores it.
        'height': widget._effectiveHeight,
        'state': (widget.state ?? widget.configuration.state)?.wireValue,
        'intent': widget.configuration.intent?.wireValue,
        'shape': widget.configuration.shape?.wireValue,
        'buttonStyle': widget.configuration.style?.wireValue,
        'theme': widget.configuration.theme?.wireValue,
      };

  Map<String, Object?> get _creationParams => <String, Object?>{
        'viewId': _viewId,
        ..._props,
      };

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
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              // Claim the gesture eagerly so taps reach the button in real time;
              // else Flutter withholds and replays the touch sequence.
              Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
            },
          ),
          onCreatePlatformView: (params) {
            // Force Hybrid Composition: under texture composition the loading spinner
            // freezes while Flutter is idle (flutter/flutter#122027).
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
            // Claim the gesture eagerly; else Flutter withholds and replays touches,
            // collapsing the button's highlight animation.
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
        );
      default:
        return ErrorWidget(
          'KlarnaPaymentButton is not supported on $defaultTargetPlatform',
        );
    }
    return SizedBox(height: widget._effectiveHeight, child: platformView);
  }
}
