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
            return
        }
    }
    
    private func initialize(method: KlarnaHybridSDKMethods.Initialize, result: @escaping FlutterResult) {
        if KlarnaHybridSDKHandler.hybridSDK == nil {
            KlarnaHybridSDKHandler.hybridSDK = KlarnaHybridSDK.init(returnUrl: URL.init(string: method.returnUrl)!, eventListener: KlarnaHybridSDKHandler.hybridSDKEventListener)
            result(nil)
        } else {
            result(FlutterError.init(code: "", message: "", details: ""))
        }
    }
}
