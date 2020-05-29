import Flutter
import WebKit
import KlarnaMobileSDK

class PostPurchaseHandler: BaseMethodHandler<PostPurchaseMethod> {
    
    init() {
        super.init(parser: PostPurchaseMethods.Parser())
    }
    
    let webViewManager = WebViewManager()
    
    var navigationDelegate: PostPurchaseWKNavigationDelegate?
    
    lazy var scriptMessageHandler: PostPurchaseScriptMessageHandler = {
        let handler = PostPurchaseScriptMessageHandler()
        handler.delegate = self
        return handler
    }()
    
    var initialized = false
    
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
        if (webViewManager.webView != nil || initialized) {
            result(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: "Already initialized.", details: nil))
            return
        }
        
        if let hybridSDK = KlarnaHybridSDKHandler.hybridSDK {
            navigationDelegate = PostPurchaseWKNavigationDelegate(hybridSDK: hybridSDK)
        } else {
            KlarnaHybridSDKHandler.notInitialized(result: result)
            return
        }
        
        let contentController = WKUserContentController()
        contentController.add(scriptMessageHandler.onInitialized, name: "onInitialized")
        contentController.add(scriptMessageHandler.onRenderOperation, name: "onRenderOperation")
        contentController.add(scriptMessageHandler.onAuthorazationRequest, name: "onAuthorazationRequest")
        webViewManager.webConfiguration.userContentController = contentController
        webViewManager.initialize(result: nil)
        webViewManager.addToHybridSdk(result: nil)

        let webView = webViewManager.requireWebview()
        webView.navigationDelegate = navigationDelegate
        let url = Bundle(for: PostPurchaseHandler.self).url(forResource: "index", withExtension: "html")!
        webView.load(URLRequest.init(url: url))

        let initScript = "window.initialize(\(method.locale.jsScriptString()), \(method.purchaseCountry.jsScriptString()), \(method.design.jsScriptString()))"
        _ = navigationDelegate?.queueJS(webViewManager: webViewManager, script: initScript)
    }
    
    private func renderOperation(method: PostPurchaseMethods.RenderOperation, result: @escaping FlutterResult) {
        // TODO
    }
    
    private func authorizationRequest(method: PostPurchaseMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        // TODO
    }
    
    
}

extension PostPurchaseHandler: PostPurchaseScriptCallbackDelegate {
    func onInitialized(success: Bool, error: String?) {
        
    }
    
    func onAuthorizationRequest(success: Bool, error: String?) {
        
    }
    
    func onRenderOperation(success: Bool, data: String?, error: String?) {
        
    }
    
    
}
