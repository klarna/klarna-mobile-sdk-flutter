import KlarnaMobileSDK

class PluginKlarnaHybridEventListener: KlarnaHybridEventListener {
    
    var result: FlutterResult?
    
    func klarnaWillShowFullscreen(inWebView webView: KlarnaWebView, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func klarnaDidShowFullscreen(inWebView webView: KlarnaWebView, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func klarnaWillHideFullscreen(inWebView webView: KlarnaWebView, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func klarnaDidHideFullscreen(inWebView webView: KlarnaWebView, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func klarnaFailed(inWebView webView: KlarnaWebView, withError error: KlarnaMobileSDKError) {
        let errorMessage = "\(error.name):\(error.message):\(error.isFatal)"
        result?(FlutterError.init(code: ResultError.hybridSdkError.rawValue, message: errorMessage, details: error.message))
        ErrorCallbackHandler.instance.sendValue(value: errorMessage)
    }
    
    
}
