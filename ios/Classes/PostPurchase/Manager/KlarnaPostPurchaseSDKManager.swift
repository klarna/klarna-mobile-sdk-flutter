import Flutter
import WebKit
import KlarnaMobileSDK

class KlarnaPostPurchaseSDKManager {
    
    static let NOT_INITIAILIZED = "KlarnaPostPurchaseSDK is not initialized"
    
    static func notInitialized(result: FlutterResult?) {
        result?(FlutterError.init(code: ResultError.klarnaPostPurchaseSDKError.rawValue, message: NOT_INITIAILIZED, details: "Call 'KlarnaPostPurchaseSDK.createInstance' before using this"))
    }
    
    let id: Int
    var postPurchaseSDK: KlarnaPostPurchaseSDK?
    var postPurchaseSDKEventListener: KlarnaPostPurchaseEventListener
    
    init(id: Int) {
        self.id = id
        self.postPurchaseSDKEventListener = KlarnaPostPurchaseSDKEventListenerImpl(id: id)
    }
    
    func create(method: KlarnaPostPurchaseSDKMethods.Create, result: @escaping FlutterResult) {
        let environment = KlarnaParamMapper.getEnvironmentOrDefault(param: method.environment)
        let region = KlarnaParamMapper.getRegionOrDefault(param: method.region)
        let resourceEndpoint = KlarnaParamMapper.getResourceEndpointOrDefault(param: method.resourceEndpoint)
        postPurchaseSDK = KlarnaPostPurchaseSDK(environment: environment, region: region, resourceEndpoint: resourceEndpoint, listener: postPurchaseSDKEventListener)
        if let returnURLString = method.returnURL {
            postPurchaseSDK?.returnURL = URL(string: returnURLString)
        }
        result(nil)
    }
    
    func initialize(method: KlarnaPostPurchaseSDKMethods.Initialize, result: @escaping FlutterResult) {
        if let postPurchaseSDK = postPurchaseSDK {
            postPurchaseSDK.initialize(locale: method.locale, purchaseCountry: method.purchaseCountry, design: method.design)
            result(nil)
        } else {
            KlarnaPostPurchaseSDKManager.notInitialized(result: result)
        }
    }
    
    func authorizationRequest(method: KlarnaPostPurchaseSDKMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        if let postPurchaseSDK = postPurchaseSDK {
            postPurchaseSDK.authorizationRequest(clientId: method.clientId, scope: method.scope, redirectUri: method.redirectUri, locale: method.locale, state: method.state, loginHint: method.loginHint, responseType: method.responseType)
            result(nil)
        } else {
            KlarnaPostPurchaseSDKManager.notInitialized(result: result)
        }
    }
    
    func renderOperation(method: KlarnaPostPurchaseSDKMethods.RenderOperation, result: @escaping FlutterResult) {
        if let postPurchaseSDK = postPurchaseSDK {
            postPurchaseSDK.renderOperation(operationToken: method.operationToken, locale: method.locale, redirectUri: method.redirectUri)
            result(nil)
        } else {
            KlarnaPostPurchaseSDKManager.notInitialized(result: result)
        }
    }
    
    func destroy(method: KlarnaPostPurchaseSDKMethods.Destroy, result: @escaping FlutterResult) {
        postPurchaseSDK = nil
        result(nil)
    }
    
}
