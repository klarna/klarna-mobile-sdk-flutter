import Flutter
import UIKit

class PaymentViewPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = PaymentViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "plugins/klarna_payment_view")
    }
}
