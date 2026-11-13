import Flutter
import UIKit

public class KlarnaNetworkMessagingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()

    let api = KnMessagingHostApiImpl()
    KnMessagingHostApiSetup.setUp(binaryMessenger: messenger, api: api)

    let factory = KlarnaMessagingPlacementViewFactory(messenger: messenger)
    registrar.register(factory, withId: "com.klarna.mobile.sdk/messaging_placement")
  }
}
