import Foundation
import KlarnaMobileSDK

protocol KlarnaPostPurchaseSDKListenerEvent {
    var id: Int { get }
    var name: String { get }
}

class KlarnaPostPurchaseSDKListenerEvents {
    
    struct OnInitialized: KlarnaPostPurchaseSDKListenerEvent, Encodable {
        let id: Int
        var name: String = "onInitialized"
    }
    
    struct OnAuthorizeRequested: KlarnaPostPurchaseSDKListenerEvent, Encodable {
        let id: Int
        var name: String = "onAuthorizeRequested"
    }
    
    struct OnRenderedOperation: KlarnaPostPurchaseSDKListenerEvent, Encodable {
        let id: Int
        var name: String = "onRenderedOperation"
        let renderResult: KlarnaPostPurchaseRenderResult
    }
    
//    struct OnError: KlarnaPostPurchaseSDKListenerEvent, Decodable {
//        let id: Int
//        var name: String = "onError"
//        let error: KlarnaPostPurchaseError
//    }
}
