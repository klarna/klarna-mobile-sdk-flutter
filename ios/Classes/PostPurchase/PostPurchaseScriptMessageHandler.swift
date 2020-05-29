import WebKit

protocol PostPurchaseScriptCallbackDelegate: class {
    func onInitialized(success: Bool, error: String?)
    func onRenderOperation(success: Bool, data: String?, error: String?)
    func onAuthorizationRequest(success: Bool, error: String?)
}

class PostPurchaseScriptMessageHandler {
    
    weak var delegate: PostPurchaseScriptCallbackDelegate?
    
    let onInitialized: OnInitialized = OnInitialized()
    let onRenderOperation: OnRenderOperation = OnRenderOperation()
    let onAuthorazationRequest: OnAuthorizationRequest = OnAuthorizationRequest()
    
    init() {
        onInitialized.parent = self
        onRenderOperation.parent = self
        onAuthorazationRequest.parent = self
    }
    
    internal class OnInitialized: NSObject, WKScriptMessageHandler {
        weak var parent: PostPurchaseScriptMessageHandler?
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            let error = message.body as? String
            let success = error == nil || error == "null" || error == "undefined"
            parent?.delegate?.onInitialized(success: success, error: error)
        }
    }
    
    internal class OnRenderOperation: NSObject, WKScriptMessageHandler {
        weak var parent: PostPurchaseScriptMessageHandler?
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let resultDict = message.body as? [String: Any] else {
                parent?.delegate?.onRenderOperation(success: false, data: nil, error: nil)
                return
            }
            let data = resultDict["data"] as? String
            let error = resultDict["error"] as? String
            
            let success = error == nil || error == "null" || error == "undefined"

            parent?.delegate?.onRenderOperation(success: success, data: data, error: error)
        }
    }
    
    internal class OnAuthorizationRequest: NSObject, WKScriptMessageHandler {
        weak var parent: PostPurchaseScriptMessageHandler?
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            let error = message.body as? String
            let success = error == nil || error == "null" || error == "undefined"
            parent?.delegate?.onAuthorizationRequest(success: success, error: error)
        }
    }
}
