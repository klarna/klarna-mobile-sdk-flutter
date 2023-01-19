import Flutter

protocol KlarnaPostPurchaseSDKMethod {
    var id: Int { get }
}

class KlarnaPostPurchaseSDKMethods {
    
    struct Create: KlarnaPostPurchaseSDKMethod, Decodable {
        let id: Int
        let environment: String?
        let region: String?
        let resourceEndpoint: String?
    }

    struct Initialize: KlarnaPostPurchaseSDKMethod, Decodable {
        let id: Int
        let locale: String
        let purchaseCountry: String
        let design: String?
    }
    
    struct AuthorizationRequest: KlarnaPostPurchaseSDKMethod, Decodable {
        let id: Int
        let clientId: String
        let scope: String
        let redirectUri: String
        let locale: String?
        let state: String?
        let loginHint: String?
        let responseType: String?
    }
    
    struct RenderOperation: KlarnaPostPurchaseSDKMethod, Decodable {
        let id: Int
        let operationToken: String
        let locale: String?
        let redirectUri: String?
    }
    
    struct Destroy: KlarnaPostPurchaseSDKMethod {
        let id: Int
    }

    class Parser: MethodParser<KlarnaPostPurchaseSDKMethod> {
        override func parse(call: FlutterMethodCall) throws -> KlarnaPostPurchaseSDKMethod? {
            switch call.method {
            case "create":
                return call.decode(Create.self)
            case "initialize":
                return call.decode(Initialize.self)
            case "renderOperation":
                return call.decode(RenderOperation.self)
            case "authorizationRequest":
                return call.decode(AuthorizationRequest.self)
            case "destroy":
                return Destroy(id: try call.requireArgument(key: "id"))
            default:
                return nil
            }
        }
    }
}
