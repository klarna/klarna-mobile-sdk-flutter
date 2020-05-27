import Flutter

protocol KlarnaHybridSDKMethod {
    
}

class KlarnaHybridSDKMethods {

    struct Initialize: KlarnaHybridSDKMethod {
        let returnUrl: String
    }

    class Parser: MethodParser<KlarnaHybridSDKMethod> {
        override func parse(call: FlutterMethodCall) -> KlarnaHybridSDKMethod? {
            switch call.method {
            case "initialize":
                return Initialize(returnUrl: "")
            default:
                return nil
            }
        }
    }
}

