import Flutter
import UIKit

public class KlarnaNetworkMessagingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = KlarnaMessagingPlacementViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "com.klarna.mobile.sdk/messaging_placement")
  }
}
