import Flutter
import os

// MARK: - SwiftFlutterKlarnaInappSdk
public class SwiftFlutterKlarnaInappSdk: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let osLog = OSLog(subsystem: "Flutter", category: "KlarnaInappSdk")
        os_log("register event", log: osLog, type: .debug)

        let messenger = registrar.messenger()
        
        getMethodHandlerMap().forEach { (key, value) in
            let channel = FlutterMethodChannel(name: key, binaryMessenger: messenger)
            registrar.addMethodCallDelegate(value, channel: channel)
        }
        
        getStreamHandlerMap().forEach { (key, value) in
            let channel = FlutterEventChannel(name: key, binaryMessenger: messenger)
            channel.setStreamHandler(value)
        }
    }
    
    static func getMethodHandlerMap() -> [String: FlutterPlugin] {
        return [
            "klarna_hybrid_sdk": KlarnaHybridSDKHandler(),
            "klarna_post_purchase_experience": PostPurchaseHandler()
        ]
    }
    
    static func getStreamHandlerMap() -> [String: FlutterStreamHandler & NSObjectProtocol] {
        return [
            "klarna_events": EventCallbackHandler.instance,
            "klarna_errors": ErrorCallbackHandler.instance,
            "klarna_hybrid_sdk_events": KlarnaHybridSDKEventHandler.instance
        ]
    }
}
