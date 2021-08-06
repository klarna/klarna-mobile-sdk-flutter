import Flutter
import UIKit
import KlarnaMobileSDK

class PaymentViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return PaymentView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args as? Dictionary<String, Any> ?? [:],
            binaryMessenger: messenger)
    }
}

class PaymentView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var klarnaHeightConstraint: NSLayoutConstraint?
    private var methodChannel: FlutterMethodChannel
    private var callbackMethodChannel: FlutterMethodChannel
    private var paymentView: KlarnaPaymentView?
    private var category: String

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Dictionary<String, Any>,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        let channelName = "plugins/klarna_payment_view_\(viewId)"
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger!)
        self.callbackMethodChannel = FlutterMethodChannel(name: "klarna_payment_callbacks", binaryMessenger: messenger!)
        self.category = args["category"] as! String
        callbackMethodChannel.invokeMethod("onInitialized", arguments: nil)

        _view = UIView()
        
        super.init()

        self.methodChannel.setMethodCallHandler(onMethodCall)

        createPaymentView(view: _view)
    }

    func view() -> UIView {
        return _view
    }

    func onMethodCall(_ methodCall: FlutterMethodCall, result: FlutterResult) {
        switch methodCall.method {
            case "initialize":
                self.initialize(call: methodCall, result: result)
            case "load":
                self.load(call: methodCall, result: result)
            case "authorize":
                self.authorize(call: methodCall, result: result)
            default: result(FlutterMethodNotImplemented)
        }
    }

    func initialize(call: FlutterMethodCall, result: FlutterResult) -> Void {
        let args = call.arguments as? [String: Any] ?? [:]
        let clientToken = args["clientToken"] as! String
        let returnUrl = args["returnUrl"] as! String
        paymentView!.initialize(clientToken: clientToken, returnUrl: URL(string: returnUrl)!)
    }

    func load(call: FlutterMethodCall, result: FlutterResult) -> Void {
        let args = call.arguments as? [String: Any] ?? [:]
        let loadArgs = args["args"] as? String
        paymentView!.load(jsonData: loadArgs)
    }

    func authorize(call: FlutterMethodCall, result: FlutterResult) -> Void {
        let args = call.arguments as? [String: Any] ?? [:]
        let autoFinalize = args["autoFinalize"] as! Bool
        let sessionData = args["sessionData"] as? String
        paymentView!.authorize(autoFinalize: autoFinalize, jsonData: sessionData)
    }

    func createPaymentView(view _view: UIView){
        self.paymentView = KlarnaPaymentView(category: category, eventListener: self)

        paymentView!.translatesAutoresizingMaskIntoConstraints = false
        self.klarnaHeightConstraint = paymentView!.heightAnchor.constraint(equalToConstant: 0)
        klarnaHeightConstraint?.isActive = true

        _view.addSubview(paymentView!)

        NSLayoutConstraint.activate([
            paymentView!.widthAnchor.constraint(equalTo: _view.widthAnchor),
            paymentView!.centerXAnchor.constraint(equalTo: _view.centerXAnchor)
        ])
    }
}

extension PaymentView: KlarnaPaymentEventListener {
    func klarnaResized(paymentView: KlarnaPaymentView, to newHeight: CGFloat) {
        self.klarnaHeightConstraint!.constant = newHeight
    }

    func klarnaInitialized(paymentView: KlarnaPaymentView) {
        self.methodChannel.invokeMethod("onInitialized", arguments: nil)
    }

    func klarnaLoaded(paymentView: KlarnaPaymentView) {
        self.methodChannel.invokeMethod("onLoaded", arguments: nil)
    }

    func klarnaLoadedPaymentReview(paymentView: KlarnaPaymentView) {
        self.methodChannel.invokeMethod("onLoadPaymentReview", arguments: nil)
    }

    func klarnaAuthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?, finalizeRequired: Bool) {
        let args: [String: Any?] = ["approved": approved, "authToken": authToken, "finalizeRequired": finalizeRequired]
        self.methodChannel.invokeMethod("onAuthorized", arguments: args)
    }

    func klarnaReauthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) {
        let args: [String: Any?] = ["approved": approved, "authToken": authToken]
        self.methodChannel.invokeMethod("onReauthorized", arguments: args)
    }

    func klarnaFinalized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) {
        let args: [String: Any?]  = ["approved": approved, "authToken": authToken]
        self.methodChannel.invokeMethod("onFinalized", arguments: args)
    }

    func klarnaFailed(inPaymentView: KlarnaPaymentView, withError: KlarnaPaymentError){
        let args: [String: Any?]  = [
            "invalidFields": withError.invalidFields, 
            "action": withError.action,
            "isFatal": withError.isFatal,
            "name": withError.name,
            "message": withError.message
        ]
        self.methodChannel.invokeMethod("onErrorOccurred", arguments: args)
    }
}