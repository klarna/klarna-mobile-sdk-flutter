import KlarnaMobileSDK

internal class KlarnaPostPurchaseSDKEventListenerImpl: KlarnaPostPurchaseEventListener {
    
    let id: Int
    
    
    init(id: Int) {
        self.id = id
    }
    
    func onAuthorizeRequested(klarnaPostPurchaseSDK: KlarnaMobileSDK.KlarnaPostPurchaseSDK) {
        let event = KlarnaPostPurchaseSDKListenerEvents.OnAuthorizeRequested(id: id)
        if let eventJson = try? JSONEncoder().encode(event) {
            let eventJsonString = String(decoding: eventJson, as: UTF8.self)
            KlarnaPostPurchaseSDKEventHandler.instance.sendValue(value: eventJsonString)
        } else {
            // TODO
        }
    }
    
    func onInitialized(klarnaPostPurchaseSDK: KlarnaMobileSDK.KlarnaPostPurchaseSDK) {
        // TODO
    }
    
    func onRenderedOperation(klarnaPostPurchaseSDK: KlarnaMobileSDK.KlarnaPostPurchaseSDK, result: KlarnaMobileSDK.KlarnaPostPurchaseRenderResult) {
        // TODO
    }
    
    func onError(klarnaPostPurchaseSDK: KlarnaMobileSDK.KlarnaPostPurchaseSDK, error: KlarnaMobileSDK.KlarnaPostPurchaseError) {
        // TODO
    }
    
}
