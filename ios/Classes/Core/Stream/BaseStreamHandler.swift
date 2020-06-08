import Flutter

protocol StreamHandler {
    func sendValue(value: String?)
}

class BaseStreamHandler: NSObject, FlutterStreamHandler, StreamHandler {
    
    private var sink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    func sendValue(value: String?) {
        sink?(value)
    }
    
    
}
