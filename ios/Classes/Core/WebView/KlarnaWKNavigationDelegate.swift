import WebKit
import KlarnaMobileSDK

class KlarnaWKNavigationDelegate: NSObject, WKNavigationDelegate {
    
    let klarnaHybridSDK: KlarnaHybridSDK
    
    init(hybridSDK: KlarnaHybridSDK) {
        self.klarnaHybridSDK = hybridSDK
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        klarnaHybridSDK.newPageLoad(in: webView)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let shouldFollow = klarnaHybridSDK.shouldFollowNavigation(withRequest: navigationAction.request)
        decisionHandler(shouldFollow ? .allow : .cancel)
    }
}
