import Flutter

protocol WebViewMethod {
    
}

class WebViewMethods {
    
    struct Initialize: WebViewMethod {}
    struct Destroy: WebViewMethod {}
    struct Show: WebViewMethod {}
    struct Hide: WebViewMethod {}
    struct LoadURL: WebViewMethod {
        let url: String
    }
    struct LoadJS: WebViewMethod {
        let js: String
    }
    struct AddToHybridSDK: WebViewMethod {}

    class Parser: MethodParser<WebViewMethod> {
        override func parse(call: FlutterMethodCall) throws -> WebViewMethod? {
            switch call.method {
            case "initialize":
                return Initialize()
            case "destroy":
                return Destroy()
            case "show":
                return Show()
            case "hide":
                return Hide()
            case "loadURL":
                return LoadURL(url: try call.requireArgument(key: "url"))
            case "loadJS":
                return LoadJS(js: try call.requireArgument(key: "js"))
            case "addToHybridSdk":
                return AddToHybridSDK()
            default:
                return nil
            }
        }
    }
}
