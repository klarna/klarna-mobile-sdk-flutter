import Flutter

/// Usage: EventCallbackHandler.instance.sendValue("web view initialized")
internal class EventCallbackHandler: BaseStreamHandler {
    
    static let instance = EventCallbackHandler()
    
    private override init() {
        
    }
}
