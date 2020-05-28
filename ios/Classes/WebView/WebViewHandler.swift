import Flutter
import UIKit
import WebKit

class WebViewHandler: BaseMethodHandler<WebViewMethod> {
    
    init() {
        super.init(parser: WebViewMethods.Parser())
    }
    
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
    
    func initialize(method: WebViewMethods.Initialize, result: @escaping FlutterResult) {
        
    }
    
    func destroy(method: WebViewMethods.Destroy, result: @escaping FlutterResult) {
        
    }
    
    func show(method: WebViewMethods.Show, result: @escaping FlutterResult) {
        
    }
    
    func hide(method: WebViewMethods.Hide, result: @escaping FlutterResult) {
        
    }
    
    func loadURL(method: WebViewMethods.LoadURL, result: @escaping FlutterResult) {
        
    }
    
    func loadJS(method: WebViewMethods.LoadJS, result: @escaping FlutterResult) {
        
    }
    
    func addToHybridSdk(method: WebViewMethods.AddToHybridSDK, result: @escaping FlutterResult) {
        
    }
    
}
