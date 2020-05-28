import Flutter
import UIKit
import WebKit
import KlarnaMobileSDK

class WebViewManager {
    
    static let NOT_INTIAILIZED = "WebView is not initialized"
    
    static func notInitialized(result: FlutterResult?) {
        result?(FlutterError.init(code: ResultError.webViewError.rawValue, message: NOT_INTIAILIZED, details: "Call 'initialize' before using this method."))
    }
    
    var webView: WKWebView?
    var webViewController: WKWebViewController?
    var webConfiguration: WKWebViewConfiguration = WKWebViewConfiguration()
    var navigationDelegate: WKNavigationDelegate? {
        didSet {
            webView?.navigationDelegate = navigationDelegate
        }
    }
    
    func initialize(result: FlutterResult?) {
        if webView == nil {
            webView = WKWebView.init(frame: .zero, configuration: webConfiguration)
            webViewController = WKWebViewController(webView: webView!)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(webViewController!, animated: true, completion: nil)
            
            result?(nil)
        } else {
            result?(FlutterError.init(code: ResultError.webViewError.rawValue, message: "WebView is already initialized.", details: nil))
        }
    }
    
    func destroy(result: FlutterResult?) {
        if let webViewController = webViewController {
            webViewController.dismiss(animated: true, completion: { [weak self] in
                self?.webView = nil
                self?.webViewController = nil
                self?.webConfiguration = WKWebViewConfiguration()
                self?.navigationDelegate = nil
                result?(nil)
            })
        } else {
            WebViewManager.notInitialized(result: result)
        }
    }
    
    func show(result: FlutterResult?) {
        if let webView = webView {
            webView.isHidden = false
            result?(nil)
        } else {
            WebViewManager.notInitialized(result: result)
        }
    }
    
    func hide(result: FlutterResult?) {
        if let webView = webView {
            webView.isHidden = true
            result?(nil)
        } else {
            WebViewManager.notInitialized(result: result)
        }
    }
    
    func loadURL(url: String, result: FlutterResult?) {
        if let webView = webView {
            if let url = URL.init(string: url) {
                webView.load(URLRequest.init(url: url))
                result?(nil)
            } else {
                result?(FlutterError.init(code: ResultError.webViewError.rawValue, message: "Invalid URL", details: nil))
            }
        } else {
            WebViewManager.notInitialized(result: result)
        }
    }
    
    func loadJS(js: String, result: FlutterResult?) {
        if let webView = webView {
            webView.evaluateJavaScript(js) { [weak self] (any, error) in
                
            }
            result?(nil)
        } else {
            WebViewManager.notInitialized(result: result)
        }
    }
    
    func addToHybridSdk(result: FlutterResult?) {
        if let webView = webView {
            if let hybridSdk = KlarnaHybridSDKHandler.hybridSDK {
                navigationDelegate = KlarnaWKNavigationDelegate(hybridSDK: hybridSdk)
                hybridSdk.addWebView(webView)
                result?(nil)
            } else {
                KlarnaHybridSDKHandler.notInitialized(result: result)
            }
        } else {
            WebViewManager.notInitialized(result: result)
        }
    }
    
}

class WKWebViewController: UIViewController {

    private let webView: WKWebView

    init(webView: WKWebView) {
        self.webView = webView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private lazy var script = """
    """
}
