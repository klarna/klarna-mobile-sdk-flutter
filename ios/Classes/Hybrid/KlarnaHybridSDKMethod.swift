import Flutter

protocol KlarnaHybridSDKMethod {
    
}

class KlarnaHybridSDKMethods {

    struct Initialize: KlarnaHybridSDKMethod, Decodable {
        let returnUrl: String
    }

    class Parser: MethodParser<KlarnaHybridSDKMethod> {
        override func parse(call: FlutterMethodCall) throws -> KlarnaHybridSDKMethod? {
            switch call.method {
            case "initialize":
                return call.decode(Initialize.self)
            case "registerEventListener":
                return RegisterEventListener()
            default:
                return nil
            }
        }
    }

    struct RegisterEventListener: KlarnaHybridSDKMethod {

    }
}

