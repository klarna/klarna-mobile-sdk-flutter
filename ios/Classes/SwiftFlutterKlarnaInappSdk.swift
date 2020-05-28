import Flutter

// MARK: - SwiftFlutterKlarnaInappSdk
public class SwiftFlutterKlarnaInappSdk: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        
        getHandlerMap().forEach { (key, value) in
            let channel = FlutterMethodChannel(name: key, binaryMessenger: messenger)
            registrar.addMethodCallDelegate(value, channel: channel)
        }
    }
    
    static func getHandlerMap() -> [String: FlutterPlugin] {
        return [
            "klarna_hybrid_sdk": KlarnaHybridSDKHandler(),
            "klarna_web_view": WebViewHandler(),
            "klarna_post_purchase_experience": PostPurchaseHandler()
        ]
    }
}
