import Flutter
import os

// MARK: - SwiftKlarnaMobileSdkFlutter
public class SwiftKlarnaMobileSdkFlutter: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let osLog = OSLog(subsystem: "Flutter", category: "KlarnaMobileSdk")
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
            "klarna_post_purchase_sdk": KlarnaPostPurchaseSDKHandler()
        ]
    }
    
    static func getStreamHandlerMap() -> [String: FlutterStreamHandler & NSObjectProtocol] {
        return [
            "klarna_post_purchase_sdk_events": KlarnaPostPurchaseSDKEventHandler.instance
        ]
    }
}
