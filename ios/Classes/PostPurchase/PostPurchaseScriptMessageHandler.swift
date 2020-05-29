import WebKit

protocol PostPurchaseScriptCallbackDelegate: class {
    func onInitialized(success: Bool, error: String?)
    func onAuthorizationRequest(success: Bool, error: String?)
    func onRenderOperation(success: Bool, data: String?, error: String?)
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
            print(message)
            parent?.delegate?.onInitialized(success: true, error: nil)
        }
    }
    
    internal class OnRenderOperation: NSObject, WKScriptMessageHandler {
        weak var parent: PostPurchaseScriptMessageHandler?
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message)
            parent?.delegate?.onRenderOperation(success: true, data: nil, error: nil)
        }
    }
    
    internal class OnAuthorizationRequest: NSObject, WKScriptMessageHandler {
        weak var parent: PostPurchaseScriptMessageHandler?
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message)
            parent?.delegate?.onAuthorizationRequest(success: true, error: nil)
        }
    }
}
