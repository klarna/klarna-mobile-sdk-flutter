import Flutter
import KlarnaMobileSDK

class KlarnaHybridSDKHandler: BaseMethodHandler<KlarnaHybridSDKMethod> {
    
    init() {
        super.init(parser: KlarnaHybridSDK.Parser())
    }
    
    override func onMethod(method: KlarnaHybridSDKMethod, result: @escaping FlutterResult) {
        switch method {
        case is KlarnaHybridSDK.Initialize:
            initialize(method: method as! KlarnaHybridSDK.Initialize, result: result)
        default:
            return
        }
    }
    
    private func initialize(method: KlarnaHybridSDK.Initialize, result: @escaping FlutterResult) {
        
    }
}
