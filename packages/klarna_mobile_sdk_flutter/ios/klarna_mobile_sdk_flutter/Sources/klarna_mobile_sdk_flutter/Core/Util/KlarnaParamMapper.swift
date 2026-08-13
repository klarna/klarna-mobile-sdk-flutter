import KlarnaMobileSDK

internal class KlarnaParamMapper {
    
    static func getEnvironment(param: String?) -> KlarnaEnvironment? {
        // Map explicitly rather than via KVC `value(forKey:)`, which throws an
        // NSUnknownKeyException (not a catchable Swift error) on an unrecognized
        // key — that would crash instead of falling back to the default.
        switch param?.lowercased() {
        case "staging":
            return KlarnaEnvironment.staging
        case "playground":
            return KlarnaEnvironment.playground
        case "production":
            return KlarnaEnvironment.production
        default:
            return nil
        }
    }

    static func getEnvironmentOrDefault(param: String?) -> KlarnaEnvironment {
        return getEnvironment(param: param) ?? KlarnaEnvironment.production
    }

    static func getRegion(param: String?) -> KlarnaRegion? {
        // See getEnvironment — explicit mapping avoids the KVC throw on unknown keys.
        switch param?.lowercased() {
        case "eu":
            return KlarnaRegion.eu
        case "na":
            return KlarnaRegion.na
        case "oc":
            return KlarnaRegion.oc
        default:
            return nil
        }
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
