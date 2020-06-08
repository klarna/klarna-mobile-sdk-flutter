import Flutter
import UIKit
import WebKit

class WebViewHandler: BaseMethodHandler<WebViewMethod> {
    
    init() {
        super.init(parser: WebViewMethods.Parser())
    }
    
    let webViewManager = WebViewManager()
    
    override func onMethod(method: WebViewMethod, result: @escaping FlutterResult) {
        switch method {
        case is WebViewMethods.Initialize:
            initialize(method: method as! WebViewMethods.Initialize, result: result)
        case is WebViewMethods.Destroy:
            destroy(method: method as! WebViewMethods.Destroy, result: result)
        case is WebViewMethods.Show:
            show(method: method as! WebViewMethods.Show, result: result)
        case is WebViewMethods.Hide:
            hide(method: method as! WebViewMethods.Hide, result: result)
        case is WebViewMethods.LoadURL:
            loadURL(method: method as! WebViewMethods.LoadURL, result: result)
        case is WebViewMethods.LoadJS:
            loadJS(method: method as! WebViewMethods.LoadJS, result: result)
        case is WebViewMethods.AddToHybridSDK:
            addToHybridSdk(method: method as! WebViewMethods.AddToHybridSDK, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(method: WebViewMethods.Initialize, result: @escaping FlutterResult) {
        webViewManager.initialize(result: result)
    }
    
    private func destroy(method: WebViewMethods.Destroy, result: @escaping FlutterResult) {
        webViewManager.destroy(result: result)
    }
    
    private func show(method: WebViewMethods.Show, result: @escaping FlutterResult) {
        webViewManager.show(result: result)
    }
    
    private func hide(method: WebViewMethods.Hide, result: @escaping FlutterResult) {
        webViewManager.hide(result: result)
    }
    
    private func loadURL(method: WebViewMethods.LoadURL, result: @escaping FlutterResult) {
        webViewManager.loadURL(url: method.url, result: result)
    }
    
    private func loadJS(method: WebViewMethods.LoadJS, result: @escaping FlutterResult) {
        webViewManager.loadJS(js: method.js, result: result)
    }
    
    private func addToHybridSdk(method: WebViewMethods.AddToHybridSDK, result: @escaping FlutterResult) {
        webViewManager.addToHybridSdk(result: result)
    }
    
}
