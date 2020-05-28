import Flutter
import KlarnaMobileSDK

class KlarnaHybridSDKHandler: BaseMethodHandler<KlarnaHybridSDKMethod> {
    
    static var hybridSDK: KlarnaHybridSDK? = nil
    static var hybridSDKEventListener: KlarnaHybridEventListener = PluginKlarnaHybridEventListener()
    
    init() {
        super.init(parser: KlarnaHybridSDKMethods.Parser())
    }
    
    override func onMethod(method: KlarnaHybridSDKMethod, result: @escaping FlutterResult) {
        switch method {
        case is KlarnaHybridSDKMethods.Initialize:
            initialize(method: method as! KlarnaHybridSDKMethods.Initialize, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(method: KlarnaHybridSDKMethods.Initialize, result: @escaping FlutterResult) {
        if KlarnaHybridSDKHandler.hybridSDK == nil {
            if let returnUrl = URL.init(string: method.returnUrl) {
                KlarnaHybridSDKHandler.hybridSDK = KlarnaHybridSDK.init(returnUrl: returnUrl, eventListener: KlarnaHybridSDKHandler.hybridSDKEventListener)
                result(nil)
            } else {
                result(FlutterError.init(code: ResultError.hybridSdkError.rawValue, message: "Invalid ReturnURL.", details: nil))
            }
        } else {
            result(FlutterError.init(code: ResultError.hybridSdkError.rawValue, message: "Already initialized.", details: nil))
        }
    }
}
