import Flutter

/// Usage: ErrorCallbackHandler.instance.sendValue("web view initialize failed")
internal class ErrorCallbackHandler: BaseStreamHandler {
    
    static let instance = ErrorCallbackHandler()
    
    private override init() {
        
    }
}
