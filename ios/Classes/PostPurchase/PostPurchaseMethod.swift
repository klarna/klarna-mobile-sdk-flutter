import Flutter

protocol PostPurchaseMethod {
    
}

class PostPurchaseMethods {

    struct Initialize: PostPurchaseMethod, Decodable {
        let locale: String
        let purchaseCountry: String
        let design: String?
    }
    
    struct Destroy: PostPurchaseMethod {}
    
    struct RenderOperation: PostPurchaseMethod, Decodable {
        let locale: String?
        let operationToken: String?
    }
    
    struct AuthorizationRequest: PostPurchaseMethod, Decodable {
        let locale: String?
        let clientId: String
        let scope: String
        let redirectUri: String
        let state: String?
        let loginHint: String?
        let responseType: String?
    }

    class Parser: MethodParser<PostPurchaseMethod> {
        override func parse(call: FlutterMethodCall) throws -> PostPurchaseMethod? {
            switch call.method {
            case "initialize":
                return call.decode(Initialize.self)
            case "destroy":
                return Destroy()
            case "renderOperation":
                return call.decode(RenderOperation.self)
            case "authorizationRequest":
                return call.decode(AuthorizationRequest.self)
            default:
                return nil
            }
        }
    }
}
