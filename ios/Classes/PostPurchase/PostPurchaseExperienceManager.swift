import Flutter
import WebKit
import KlarnaMobileSDK

class PostPurchaseExperienceManager {
    
    static let NOT_INITIAILIZED = "PostPurchaseExperience is not initialized"
    
    static func notInitialized(result: FlutterResult?) {
        result?(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: NOT_INITIAILIZED, details: "Call 'PostPurchaseExperience.initialize' before using this"))
    }
    
    var webViewManager = WebViewManager()
    
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
    
    func initialize(method: PostPurchaseMethods.Initialize, result: @escaping FlutterResult) {
        if (webViewManager.webView != nil) {
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
        contentController.add(scriptMessageHandler, name: "PPECallback")
        webViewManager.webConfiguration.userContentController = contentController
        webViewManager.initialize(result: nil)
        webViewManager.addToHybridSdk(result: nil)

        let webView = webViewManager.requireWebview()
        webView.navigationDelegate = navigationDelegate
        let url = Bundle(for: PostPurchaseHandler.self).url(forResource: "ppe", withExtension: "html")!
        webView.load(URLRequest.init(url: url))

        initialized = false
        let initScript = "initialize(\(method.locale.jsScriptString()), \(method.purchaseCountry.jsScriptString()), \(method.design.jsScriptString()))"
        _ = navigationDelegate?.queueJS(webViewManager: webViewManager, script: initScript)
    }
    
    func destroy(method: PostPurchaseMethods.Destroy, result: @escaping FlutterResult) {
        webViewManager.destroy(result: nil)
        webViewManager = WebViewManager()
        navigationDelegate = nil
        initialized = false
        initResult = nil
        renderResult = nil
        authResult = nil
        result(nil)
    }
    
    func renderOperation(method: PostPurchaseMethods.RenderOperation, result: @escaping FlutterResult) {
        if (!initialized) {
            PostPurchaseExperienceManager.notInitialized(result: result)
            return
        }
        renderResult = result
        _ = navigationDelegate?.queueJS(webViewManager: webViewManager, script: "renderOperation(\(method.locale.jsScriptString()), \(method.operationToken.jsScriptString()))")
    }
    
    func authorizationRequest(method: PostPurchaseMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        if (!initialized) {
            PostPurchaseExperienceManager.notInitialized(result: result)
            return
        }
        renderResult = result
        _ = navigationDelegate?.queueJS(webViewManager: webViewManager, script: "authorizationRequest(\(method.locale.jsScriptString()), \(method.clientId.jsScriptString()), \(method.scope.jsScriptString()), \(method.redirectUri.jsScriptString()), \(method.state.jsScriptString()), \(method.loginHint.jsScriptString()), \(method.responseType.jsScriptString()))")
    }
}

extension PostPurchaseExperienceManager: PostPurchaseScriptCallbackDelegate {
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
    
    func onError(message: String?, error: Error?) {
        ErrorCallbackHandler.instance.sendValue(value: message)
    }
    
    
}
