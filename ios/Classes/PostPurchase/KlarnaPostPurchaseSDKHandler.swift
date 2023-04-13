import Flutter
import WebKit
import KlarnaMobileSDK

class KlarnaPostPurchaseSDKHandler: BaseMethodHandler<KlarnaPostPurchaseSDKMethod> {
    
    private var postPurchaseSDKManagerMap = [Int:KlarnaPostPurchaseSDKManager]()
    
    init() {
        super.init(parser: KlarnaPostPurchaseSDKMethods.Parser())
    }
    
    override func onMethod(method: KlarnaPostPurchaseSDKMethod, result: @escaping FlutterResult) {
        switch method {
        case is KlarnaPostPurchaseSDKMethods.Create:
            create(method: method as! KlarnaPostPurchaseSDKMethods.Create, result: result)
        case is KlarnaPostPurchaseSDKMethods.Initialize:
            initialize(method: method as! KlarnaPostPurchaseSDKMethods.Initialize, result: result)
        case is KlarnaPostPurchaseSDKMethods.Destroy:
            destroy(method: method as! KlarnaPostPurchaseSDKMethods.Destroy, result: result)
        case is KlarnaPostPurchaseSDKMethods.RenderOperation:
            renderOperation(method: method as! KlarnaPostPurchaseSDKMethods.RenderOperation, result: result)
        case is KlarnaPostPurchaseSDKMethods.AuthorizationRequest:
            authorizationRequest(method: method as! KlarnaPostPurchaseSDKMethods.AuthorizationRequest, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func create(method: KlarnaPostPurchaseSDKMethods.Create, result: @escaping FlutterResult) {
        if let manager = getManager(method: method) {
            manager.create(method: method, result: result)
        } else {
            let manager = KlarnaPostPurchaseSDKManager(id: method.id)
            manager.create(method: method, result: result)
            postPurchaseSDKManagerMap[method.id] = manager
        }
    }
    
    private func initialize(method: KlarnaPostPurchaseSDKMethods.Initialize, result: @escaping FlutterResult) {
        getManager(method: method)?.initialize(method: method, result: result) ?? KlarnaPostPurchaseSDKManager.notInitialized(result: result)
    }
    
    private func authorizationRequest(method: KlarnaPostPurchaseSDKMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        getManager(method: method)?.authorizationRequest(method: method, result: result) ?? KlarnaPostPurchaseSDKManager.notInitialized(result: result)
    }
    
    private func renderOperation(method: KlarnaPostPurchaseSDKMethods.RenderOperation, result: @escaping FlutterResult) {
        getManager(method: method)?.renderOperation(method: method, result: result) ?? KlarnaPostPurchaseSDKManager.notInitialized(result: result)
    }
    
    private func destroy(method: KlarnaPostPurchaseSDKMethods.Destroy, result: @escaping FlutterResult) {
        getManager(method: method)?.destroy(method: method, result: result)
        postPurchaseSDKManagerMap.removeValue(forKey: method.id)
    }
    
    private func getManager(method: KlarnaPostPurchaseSDKMethod) -> KlarnaPostPurchaseSDKManager? {
        return postPurchaseSDKManagerMap[method.id]
    }
}
