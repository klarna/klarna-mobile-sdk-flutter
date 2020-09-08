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
        if let sdkSource = method.sdkSource, !sdkSource.isEmpty {
            let html = AssetManager.readAsset(fileName: "ppe", fileExtension: "html")
            if let replaced = html?.replacingOccurrences(of: "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/sdk.js", with: sdkSource) {
                webView.loadHTMLString(replaced, baseURL: nil)
            } else {
                webView.load(URLRequest.init(url: url))
            }
        } else {
            webView.load(URLRequest.init(url: url))
        }

        initResult = result
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
        showWebView()
    }
    
    func authorizationRequest(method: PostPurchaseMethods.AuthorizationRequest, result: @escaping FlutterResult) {
        if (!initialized) {
            PostPurchaseExperienceManager.notInitialized(result: result)
            return
        }
        authResult = result
        _ = navigationDelegate?.queueJS(webViewManager: webViewManager, script: "authorizationRequest(\(method.locale.jsScriptString()), \(method.clientId.jsScriptString()), \(method.scope.jsScriptString()), \(method.redirectUri.jsScriptString()), \(method.state.jsScriptString()), \(method.loginHint.jsScriptString()), \(method.responseType.jsScriptString()))")
        showWebView()
    }
    
    private func showWebView() {
        webViewManager.show(result: nil)
        webViewManager.webViewController?.view.backgroundColor = UIColor.clear
        webViewManager.webView?.backgroundColor = UIColor.clear
        webViewManager.webView?.isOpaque = false
    }
    
    private func hideWebView() {
        webViewManager.hide(result: nil)
    }
}

extension PostPurchaseExperienceManager: PostPurchaseScriptCallbackDelegate {
    func onInitialize(success: Bool, message: String?, error: String?) {
        if (success) {
            initResult?(message)
            initialized = true
        } else {
            initResult?(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: message, details: error))
        }
        initResult = nil
    }
    
    func onRenderOperation(success: Bool, message: String?, error: String?) {
        if (success) {
            renderResult?(message)
        } else {
            renderResult?(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: message, details: error))
        }
        renderResult = nil
        hideWebView()
    }
    
    func onAuthorizationRequest(success: Bool, message: String?, error: String?) {
        if (success) {
            authResult?(message)
        } else {
            authResult?(FlutterError.init(code: ResultError.postPurchaseError.rawValue, message: message, details: error))
        }
        authResult = nil
        hideWebView()
    }
    
    func onError(message: String?, error: Error?) {
        ErrorCallbackHandler.instance.sendValue(value: message)
        hideWebView()
    }
    
    
}
