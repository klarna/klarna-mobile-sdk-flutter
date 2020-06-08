import Flutter

internal extension FlutterMethodCall {
    
    var argumentDictionary: Dictionary<String, Any>? {
        get {
            return arguments as? Dictionary<String, Any>
        }
    }
    
    var argumentData: Data? {
        get {
            if let dictionary = argumentDictionary {
                return try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            }
            return nil
        }
    }
    
    func argument<T>(key: String) -> T? {
        let value = argumentDictionary?[key]
        return value as? T
    }
    
    func requireArgument<T>(key: String) throws -> T {
        let value = argumentDictionary![key]
        if let result = value as? T {
            return result
        } else {
            throw "Argument \(key) can not be null."
        }
    }
    
    func decode<T>(_ type: T.Type) -> T? where T : Decodable {
        if let data = argumentData {
            return try? JSONDecoder().decode(type, from: data)
        } else {
            return nil
        }
    }
    
}
