import Flutter
import KlarnaMobileSDK

class PostPurchaseHandler: BaseMethodHandler<PostPurchaseMethod> {
    
    init() {
        super.init(parser: PostPurchaseMethods.Parser())
    }
    
    override func onMethod(method: PostPurchaseMethod, result: @escaping FlutterResult) {
        switch method {
        case is PostPurchaseMethods.Initialize:
            initialize(method: method as! PostPurchaseMethods.Initialize, result: result)
        case is PostPurchaseMethods.RenderOperation:
            renderOperation(method: method as! PostPurchaseMethods.RenderOperation, result: result)
        case is PostPurchaseMethods.AuthorizationRequest:
            authorizationRequest(method: method as! PostPurchaseMethods.AuthorizationRequest, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(method: PostPurchaseMethods.Initialize, result: @escaping FlutterResult) {
        // TODO
    }
    
    private func renderOperation(method: PostPurchaseMethods.RenderOperation, result: @escaping FlutterResult) {
        // TODO
    }
    
    private func authorizationRequest(method: PostPurchaseMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        // TODO
    }
    
    
}
