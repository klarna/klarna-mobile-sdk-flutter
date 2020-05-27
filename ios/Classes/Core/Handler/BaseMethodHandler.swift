import Flutter

protocol MethodHandler  {
    associatedtype MethodT
    func onMethod(method: MethodT, result: @escaping FlutterResult)
}

// MARK: - BaseMethodHandler
class BaseMethodHandler<T>: NSObject, FlutterPlugin, MethodHandler {
    typealias MethodT = T
    
    let parser: MethodParser<T>
    
    init(parser: MethodParser<T>) {
        self.parser = parser
    }
    
    @objc static func register(with registrar: FlutterPluginRegistrar) {
        // Refer to `SwiftFlutterKlarnaInappSdk`
    }
        
    final func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = parser.parse(call: call)
        if let m = method {
            onMethod(method: m, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func onMethod(method: T, result: @escaping FlutterResult) {
        
    }
    
}
