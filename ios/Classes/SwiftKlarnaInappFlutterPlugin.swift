import Flutter
import UIKit

public class SwiftKlarnaInappFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "klarna_inapp_flutter_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftKlarnaInappFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
