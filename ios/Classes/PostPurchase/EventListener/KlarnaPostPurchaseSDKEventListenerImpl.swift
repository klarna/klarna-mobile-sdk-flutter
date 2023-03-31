import KlarnaMobileSDK

internal class KlarnaPostPurchaseSDKEventListenerImpl: KlarnaPostPurchaseEventListener {

    let id: Int

    init(id: Int) {
        self.id = id
    }

    func onInitialized(klarnaPostPurchaseSDK: KlarnaMobileSDK.KlarnaPostPurchaseSDK) {
        let event = KlarnaPostPurchaseSDKListenerEvents.OnInitialized(id: id)
        if let eventJson = try? JSONEncoder().encode(event) {
            let eventJsonString = String(decoding: eventJson, as: UTF8.self)
            KlarnaPostPurchaseSDKEventHandler.instance.sendValue(value: eventJsonString)
        } else {
            failedToSendEvent(action: "onInitialized")
        }
    }

    func onAuthorizeRequested(klarnaPostPurchaseSDK: KlarnaMobileSDK.KlarnaPostPurchaseSDK) {
        let event = KlarnaPostPurchaseSDKListenerEvents.OnAuthorizeRequested(id: id)
        if let eventJson = try? JSONEncoder().encode(event) {
            let eventJsonString = String(decoding: eventJson, as: UTF8.self)
            KlarnaPostPurchaseSDKEventHandler.instance.sendValue(value: eventJsonString)
        } else {
            failedToSendEvent(action: "onAuthorizeRequested")
        }
    }

    func onRenderedOperation(klarnaPostPurchaseSDK: KlarnaMobileSDK.KlarnaPostPurchaseSDK, result: KlarnaMobileSDK.KlarnaPostPurchaseRenderResult) {
        let event = KlarnaPostPurchaseSDKListenerEvents.OnRenderedOperation(id: id, renderResult: result.stringValue)
        if let eventJson = try? JSONEncoder().encode(event) {
            let eventJsonString = String(decoding: eventJson, as: UTF8.self)
            KlarnaPostPurchaseSDKEventHandler.instance.sendValue(value: eventJsonString)
        } else {
            failedToSendEvent(action: "onRenderedOperation")
        }
    }

    func onError(klarnaPostPurchaseSDK: KlarnaMobileSDK.KlarnaPostPurchaseSDK, error: KlarnaMobileSDK.KlarnaPostPurchaseError) {
        let errorWrapper = KlarnaPostPurchaseErrorWrapper(name: error.name, message: error.message, isFatal: error.isFatal, status: error.status)
        let event = KlarnaPostPurchaseSDKListenerEvents.OnError(id: id, error: errorWrapper)
        if let eventJson = try? JSONEncoder().encode(event) {
            let eventJsonString = String(decoding: eventJson, as: UTF8.self)
            KlarnaPostPurchaseSDKEventHandler.instance.sendValue(value: eventJsonString)
        } else {
            failedToSendEvent(action: "onError")
        }
    }
    
    private func failedToSendEvent(action: String) {
        let errorWrapper = KlarnaPostPurchaseErrorWrapper(name: "FailedToSendNativeEventToFlutter", message: "An error occured while sending message to flutter on action: \(action)", isFatal: true, status: nil)
        let event = KlarnaPostPurchaseSDKListenerEvents.OnError(id: id, error: errorWrapper)
        if let eventJson = try? JSONEncoder().encode(event) {
            let eventJsonString = String(decoding: eventJson, as: UTF8.self)
            KlarnaPostPurchaseSDKEventHandler.instance.sendValue(value: eventJsonString)
        }
    }

}
