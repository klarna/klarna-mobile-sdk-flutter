import UIKit
import WebKit

class PostPurchaseWKNavigationDelegate: KlarnaWKNavigationDelegate {
    
    private var loaded = false

    private var scriptQueue = [String]()
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loaded = true
        
        if !scriptQueue.isEmpty {
            let queue = scriptQueue.map { $0 }
            scriptQueue = []
            for script in queue {
                webView.evaluateJavaScript(script) { [weak self] (any, error) in
                    
                }
            }
        }
    }
    
    func queueJS(webViewManager: WebViewManager, script: String) -> Bool {
        if (loaded) {
            webViewManager.loadJS(js: script, result: nil)
            return true
        } else {
            scriptQueue.append(script)
            return false
        }
    }
}
