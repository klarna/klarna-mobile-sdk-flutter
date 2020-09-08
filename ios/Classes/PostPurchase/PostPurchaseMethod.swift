import Flutter

protocol PostPurchaseMethod {
    var id: Int { get }
}

class PostPurchaseMethods {

    struct Initialize: PostPurchaseMethod, Decodable {
        let id: Int
        let locale: String
        let purchaseCountry: String
        let design: String?
        let sdkSource: String?
    }
    
    struct Destroy: PostPurchaseMethod {
        let id: Int
    }
    
    struct RenderOperation: PostPurchaseMethod, Decodable {
        let id: Int
        let locale: String?
        let operationToken: String?
    }
    
    struct AuthorizationRequest: PostPurchaseMethod, Decodable {
        let id: Int
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
                return Destroy(id: try call.requireArgument(key: "id"))
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
