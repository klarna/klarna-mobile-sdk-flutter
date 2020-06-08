import Flutter

protocol MethodHandler  {
    associatedtype MethodT
    func onMethod(method: MethodT, result: @escaping FlutterResult) throws
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
        do {
            let method = try parser.parse(call: call)
            if let m = method {
                try onMethod(method: m, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        } catch let error {
            result(FlutterError.init(code: ResultError.pluginMethodError.rawValue, message: call.method, details: error))
        }
    }
    
    func onMethod(method: T, result: @escaping FlutterResult) throws {
        
    }
    
}
