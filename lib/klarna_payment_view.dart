import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_payment_sdk_error.dart';

const KlarnaPaymentCategoryPayNow = "pay_now";
const KlarnaPaymentCategoryPayLater = "pay_later";
const KlarnaPaymentCategorySliceIt = "pay_over_time";

typedef OnCreatedCallback = void Function(KlarnaPaymentController controller);

typedef OnAuthorizedCallback = void Function(KlarnaPaymentController controller,
    bool approved, String authToken, bool finalizeRequired);
typedef OnErrorOccurredCallback = void Function(
    KlarnaPaymentController controller, KlarnaPaymentSDKError error);
typedef OnFinalizedCallback = void Function(
    KlarnaPaymentController controller, bool approved, String authToken);
typedef OnInitializedCallback = void Function(
    KlarnaPaymentController controller);
typedef OnLoadPaymentReviewCallback = void Function(
    KlarnaPaymentController controller, bool showForm);
typedef OnLoadedCallback = void Function(KlarnaPaymentController controller);
typedef OnReauthorizedCallback = void Function(
    KlarnaPaymentController controller, bool approved, String authToken);

class KlarnaPaymentView extends StatelessWidget {
  final String category;
  final OnCreatedCallback onCreated;
  final OnAuthorizedCallback onAuthorized;
  final OnErrorOccurredCallback onErrorOccurred;
  final OnFinalizedCallback onFinalized;
  final OnInitializedCallback onInitialized;
  final OnLoadPaymentReviewCallback onLoadPaymentReview;
  final OnLoadedCallback onLoaded;
  final OnReauthorizedCallback onReauthorized;
  KlarnaPaymentController _controller;

  KlarnaPaymentView({
    Key key,
    @required this.category,
    this.onCreated,
    this.onAuthorized,
    this.onErrorOccurred,
    this.onFinalized,
    this.onInitialized,
    this.onLoadPaymentReview,
    this.onLoaded,
    this.onReauthorized,
  }) : super(key: key);

  KlarnaPaymentView.payNow({
    Key key,
    this.onCreated,
    this.onAuthorized,
    this.onErrorOccurred,
    this.onFinalized,
    this.onInitialized,
    this.onLoadPaymentReview,
    this.onLoaded,
    this.onReauthorized,
  })  : category = KlarnaPaymentCategoryPayNow,
        super(key: key);

  KlarnaPaymentView.payLater({
    Key key,
    this.onCreated,
    this.onAuthorized,
    this.onErrorOccurred,
    this.onFinalized,
    this.onInitialized,
    this.onLoadPaymentReview,
    this.onLoaded,
    this.onReauthorized,
  })  : category = KlarnaPaymentCategoryPayLater,
        super(key: key);

  KlarnaPaymentView.sliceIt({
    Key key,
    this.onCreated,
    this.onAuthorized,
    this.onErrorOccurred,
    this.onFinalized,
    this.onInitialized,
    this.onLoadPaymentReview,
    this.onLoaded,
    this.onReauthorized,
  })  : category = KlarnaPaymentCategorySliceIt,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Column(
        children: <Widget>[
          Container(
            height: 300,
            child: AndroidView(
              viewType: 'plugins/klarna_payment_view',
              onPlatformViewCreated: _onPlatformViewCreated,
              creationParamsCodec: const StandardMessageCodec(),
              creationParams: <String, dynamic>{"category": category},
            ),
          ),
        ],
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        height: 300,
        child: UiKitView(
          viewType: 'plugins/klarna_payment_view',
          onPlatformViewCreated: _onPlatformViewCreated,
          layoutDirection: TextDirection.ltr,
          creationParams: <String, dynamic>{"category": category},
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    }

    return Text("Platform not supported.");
  }

  Future<void> _onPlatformViewCreated(int id) async {
    final methodChannel = MethodChannel("plugins/klarna_payment_view_$id");
    methodChannel.setMethodCallHandler(this._callbackHandler);
    final controller = KlarnaPaymentController._(id);
    onCreated(controller);

    this._controller = controller;
  }

  Future<void> _callbackHandler(MethodCall call) async {
    final args = call.arguments;
    switch (call.method) {
      case "onAuthorized":
        onAuthorized?.call(this._controller, args["approved"],
            args["authToken"], args["finalizeRequired"]);
        break;
      case "onErrorOccurred":
        final error = KlarnaPaymentSDKError(
          action: args["action"],
          invalidFields: args["invalidFields"],
          isFatal: args["isFatal"],
          message: args["message"],
          name: args["name"],
        );
        onErrorOccurred?.call(this._controller, error);
        break;
      case "onFinalized":
        onFinalized?.call(
            this._controller, args["approved"], args["authToken"]);
        break;
      case "onInitialized":
        onInitialized?.call(this._controller);
        break;
      case "onLoadPaymentReview":
        onLoadPaymentReview?.call(this._controller, args["showForm"] ?? false);
        break;
      case "onLoaded":
        onLoaded?.call(this._controller);
        break;
      case "onReauthorized":
        onReauthorized?.call(
            this._controller, args["approved"], args["authToken"]);
    }
  }
}

class KlarnaPaymentController {
  KlarnaPaymentController._(int id)
      : _channel = MethodChannel('plugins/klarna_payment_view_$id');

  final MethodChannel _channel;

  Future<void> initialize({String clientToken, String returnUrl}) async {
    return _channel.invokeMethod(
        'initialize', {"clientToken": clientToken, "returnUrl": returnUrl});
  }

  Future<void> load({String args}) async {
    return _channel.invokeMethod('load', {"args": args});
  }

  Future<void> authorize(
      {@required bool autoFinalize, String sessionData}) async {
    return _channel.invokeMethod('authorize',
        {"autoFinalize": autoFinalize, "sessionData": sessionData});
  }
}
