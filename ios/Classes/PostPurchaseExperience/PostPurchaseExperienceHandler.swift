import Flutter
import WebKit
import KlarnaMobileSDK

class PostPurchaseExperienceHandler: BaseMethodHandler<PostPurchaseExperienceMethod> {
    
    private var ppeManagerMap = [Int:PostPurchaseExperienceManager]()
    
    init() {
        super.init(parser: PostPurchaseExperienceMethods.Parser())
    }
    
    override func onMethod(method: PostPurchaseExperienceMethod, result: @escaping FlutterResult) {
        switch method {
        case is PostPurchaseExperienceMethods.Initialize:
            initialize(method: method as! PostPurchaseExperienceMethods.Initialize, result: result)
        case is PostPurchaseExperienceMethods.Destroy:
            destroy(method: method as! PostPurchaseExperienceMethods.Destroy, result: result)
        case is PostPurchaseExperienceMethods.RenderOperation:
            renderOperation(method: method as! PostPurchaseExperienceMethods.RenderOperation, result: result)
        case is PostPurchaseExperienceMethods.AuthorizationRequest:
            authorizationRequest(method: method as! PostPurchaseExperienceMethods.AuthorizationRequest, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(method: PostPurchaseExperienceMethods.Initialize, result: @escaping FlutterResult) {
        if let manager = getManager(method: method) {
            manager.initialize(method: method, result: result)
        } else {
            let manager = PostPurchaseExperienceManager()
            manager.initialize(method: method, result: result)
            ppeManagerMap[method.id] = manager
        }
    }
    
    private func destroy(method: PostPurchaseExperienceMethods.Destroy, result: @escaping FlutterResult) {
        getManager(method: method)?.destroy(method: method, result: result)
        ppeManagerMap.removeValue(forKey: method.id)
    }
    
    private func renderOperation(method: PostPurchaseExperienceMethods.RenderOperation, result: @escaping FlutterResult) {
        getManager(method: method)?.renderOperation(method: method, result: result)
    }
    
    private func authorizationRequest(method: PostPurchaseExperienceMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        getManager(method: method)?.authorizationRequest(method: method, result: result)
    }
    
    private func getManager(method: PostPurchaseExperienceMethod) -> PostPurchaseExperienceManager? {
        return ppeManagerMap[method.id]
    }
    
}
