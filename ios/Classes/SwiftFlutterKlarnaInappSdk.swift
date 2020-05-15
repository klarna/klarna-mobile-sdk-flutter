import Flutter
import UIKit

public class SwiftFlutterKlarnaInappSdk: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_klarna_inapp_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterKlarnaInappSdk()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
