import Flutter

internal extension FlutterMethodCall {
    
    var argumentMap: Dictionary<String, Any>? {
        get {
            return arguments as? Dictionary<String, Any>
        }
    }
    
    func argument<T>(key: String) -> T? {
        let value = argumentMap?[key]
        return value as? T
    }
    
    func requireArgument<T>(key: String) -> T {
        let value = argumentMap![key]
        return value as! T
    }
    
}
