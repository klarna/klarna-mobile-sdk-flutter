import Flutter
import KlarnaMobileSDK

class KlarnaHybridSDKHandler: BaseMethodHandler<KlarnaHybridSDKMethod> {
    
    static var hybridSDK: KlarnaHybridSDK? = nil
    static var hybridSDKEventListener: KlarnaHybridEventListener = PluginKlarnaHybridEventListener()
    
    static let NOT_INITIAILIZED = "KlarnaHybridSDK is not initialized"
    
    static func notInitialized(result: FlutterResult?) {
        result?(FlutterError.init(code: ResultError.hybridSdkError.rawValue, message: NOT_INITIAILIZED, details: "Call 'KlarnaHybridSDK.initialize' before using this"))
    }
    
    init() {
        super.init(parser: KlarnaHybridSDKMethods.Parser())
    }
    
    override func onMethod(method: KlarnaHybridSDKMethod, result: @escaping FlutterResult) {
        switch method {
        case is KlarnaHybridSDKMethods.Initialize:
            initialize(method: method as! KlarnaHybridSDKMethods.Initialize, result: result)
        case is KlarnaHybridSDKMethods.RegisterEventListener:
            registerEventListener(method: method as! KlarnaHybridSDKMethods.RegisterEventListener, result: result)
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

    private func registerEventListener(method: KlarnaHybridSDKMethods.RegisterEventListener, result: @escaping FlutterResult) {
        guard KlarnaHybridSDKHandler.hybridSDK != nil else {
            result(FlutterError.init(code: ResultError.hybridSdkError.rawValue, message: "Invalid callback for event listener.", details: nil))
            return
        }

        KlarnaHybridSDKHandler.hybridSDK?.registerEventListener(withCallback: { response in
            KlarnaHybridSDKEventHandler.instance.sendValue(value: response.bodyString)
        })

        result(nil)
    }
}
