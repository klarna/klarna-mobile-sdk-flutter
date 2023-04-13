import KlarnaMobileSDK

internal class KlarnaParamMapper {
    
    static func getEnvironment(param: String?) -> KlarnaEnvironment? {
        if let param = param?.lowercased() {
            return KlarnaEnvironment.value(forKey: param) as? KlarnaEnvironment
        }
        return nil
    }
    
    static func getEnvironmentOrDefault(param: String?) -> KlarnaEnvironment {
        return getEnvironment(param: param) ?? KlarnaEnvironment.production
    }
    
    static func getRegion(param: String?) -> KlarnaRegion? {
        if let param = param?.lowercased() {
            return KlarnaRegion.value(forKey: param) as? KlarnaRegion
        }
        return nil
    }
    
    static func getRegionOrDefault(param: String?) -> KlarnaRegion {
        return getRegion(param: param) ?? KlarnaRegion.eu
    }
    
    static func getResourceEndpoint(param: String?) -> KlarnaResourceEndpoint? {
        if let param = param?.lowercased() {
            switch param {
            case "alternative_1":
                return KlarnaResourceEndpoint.alternative1
            case "alternative_2":
                return KlarnaResourceEndpoint.alternative2
            default:
                return nil
            }
        }
        return nil
    }
    
    static func getResourceEndpointOrDefault(param: String?) -> KlarnaResourceEndpoint {
        return getResourceEndpoint(param: param) ?? KlarnaResourceEndpoint.alternative1
    }
}
