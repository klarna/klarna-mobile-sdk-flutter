import Flutter
import WebKit
import KlarnaMobileSDK

class PostPurchaseHandler: BaseMethodHandler<PostPurchaseMethod> {
    
    private var ppeManagerMap = [Int:PostPurchaseExperienceManager]()
    
    init() {
        super.init(parser: PostPurchaseMethods.Parser())
    }
    
    override func onMethod(method: PostPurchaseMethod, result: @escaping FlutterResult) {
        switch method {
        case is PostPurchaseMethods.Initialize:
            initialize(method: method as! PostPurchaseMethods.Initialize, result: result)
        case is PostPurchaseMethods.Destroy:
            destroy(method: method as! PostPurchaseMethods.Destroy, result: result)
        case is PostPurchaseMethods.RenderOperation:
            renderOperation(method: method as! PostPurchaseMethods.RenderOperation, result: result)
        case is PostPurchaseMethods.AuthorizationRequest:
            authorizationRequest(method: method as! PostPurchaseMethods.AuthorizationRequest, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(method: PostPurchaseMethods.Initialize, result: @escaping FlutterResult) {
        if let manager = getManager(method: method) {
            manager.initialize(method: method, result: result)
        } else {
            let manager = PostPurchaseExperienceManager()
            manager.initialize(method: method, result: result)
            ppeManagerMap[method.id] = manager
        }
    }
    
    private func destroy(method: PostPurchaseMethods.Destroy, result: @escaping FlutterResult) {
        getManager(method: method)?.destroy(method: method, result: result)
        ppeManagerMap.removeValue(forKey: method.id)
    }
    
    private func renderOperation(method: PostPurchaseMethods.RenderOperation, result: @escaping FlutterResult) {
        getManager(method: method)?.renderOperation(method: method, result: result)
    }
    
    private func authorizationRequest(method: PostPurchaseMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        getManager(method: method)?.authorizationRequest(method: method, result: result)
    }
    
    private func getManager(method: PostPurchaseMethod) -> PostPurchaseExperienceManager? {
        return ppeManagerMap[method.id]
    }
    
}
