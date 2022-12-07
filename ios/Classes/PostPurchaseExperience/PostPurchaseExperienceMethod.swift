import Flutter

protocol PostPurchaseExperienceMethod {
    var id: Int { get }
}

class PostPurchaseExperienceMethods {

    struct Initialize: PostPurchaseExperienceMethod, Decodable {
        let id: Int
        let returnUrl: String
        let locale: String
        let purchaseCountry: String
        let design: String?
        let sdkSource: String?
    }
    
    struct Destroy: PostPurchaseExperienceMethod {
        let id: Int
    }
    
    struct RenderOperation: PostPurchaseExperienceMethod, Decodable {
        let id: Int
        let locale: String?
        let operationToken: String?
    }
    
    struct AuthorizationRequest: PostPurchaseExperienceMethod, Decodable {
        let id: Int
        let locale: String?
        let clientId: String
        let scope: String
        let redirectUri: String
        let state: String?
        let loginHint: String?
        let responseType: String?
    }

    class Parser: MethodParser<PostPurchaseExperienceMethod> {
        override func parse(call: FlutterMethodCall) throws -> PostPurchaseExperienceMethod? {
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
