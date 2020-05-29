import Flutter
import WebKit
import KlarnaMobileSDK

class PostPurchaseHandler: BaseMethodHandler<PostPurchaseMethod> {
    
    static let NOT_INTIAILIZED = "PostPurchaseExperience is not initialized"
    
    static func notInitialized(result: FlutterResult?) {
        result?(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: NOT_INTIAILIZED, details: "Call 'PostPurchaseExperience.initialize' before using this"))
    }
    
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
    
    var initResult: FlutterResult?
    var authResult: FlutterResult?
    var renderResult: FlutterResult?
    
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

        let initScript = "initialize(\(method.locale.jsScriptString()), \(method.purchaseCountry.jsScriptString()), \(method.design.jsScriptString()))"
        _ = navigationDelegate?.queueJS(webViewManager: webViewManager, script: initScript)
    }
    
    private func renderOperation(method: PostPurchaseMethods.RenderOperation, result: @escaping FlutterResult) {
        if (!initialized) {
            PostPurchaseHandler.notInitialized(result: result)
            return
        }
        renderResult = result
        _ = navigationDelegate?.queueJS(webViewManager: webViewManager, script: "renderOperation(\(method.locale.jsScriptString()), \(method.operationToken.jsScriptString())")
    }
    
    private func authorizationRequest(method: PostPurchaseMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        if (!initialized) {
            PostPurchaseHandler.notInitialized(result: result)
            return
        }
        renderResult = result
        _ = navigationDelegate?.queueJS(webViewManager: webViewManager, script: "authorizationRequest(\(method.locale.jsScriptString()), \(method.clientId.jsScriptString()), \(method.scope.jsScriptString()), \(method.redirectUri.jsScriptString()), \(method.state.jsScriptString()), \(method.loginHint.jsScriptString()), \(method.responseType.jsScriptString()))")
    }
    
    
}

extension PostPurchaseHandler: PostPurchaseScriptCallbackDelegate {
    func onInitialized(success: Bool, error: String?) {
        if (success) {
            initResult?(nil)
            initialized = true
        } else {
            initResult?(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: error, details: nil))
        }
        initResult = nil
    }
    
    func onRenderOperation(success: Bool, data: String?, error: String?) {
        if (success) {
            renderResult?(data)
        } else {
            renderResult?(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: error, details: data))
        }
        renderResult = nil
    }
    
    func onAuthorizationRequest(success: Bool, error: String?) {
        if (success) {
            authResult?(nil)
        } else {
            authResult?(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: error, details: nil))
        }
        authResult = nil
    }
    
    
}
