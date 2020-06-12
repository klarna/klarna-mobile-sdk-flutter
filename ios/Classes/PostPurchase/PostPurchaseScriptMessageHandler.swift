import WebKit

internal protocol PostPurchaseScriptCallbackDelegate: class {
    func onInitialized(success: Bool, error: String?)
    func onRenderOperation(success: Bool, data: String?, error: String?)
    func onAuthorizationRequest(success: Bool, error: String?)
    func onError(message: String?, error: Error?)
}

internal class PostPurchaseScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    weak var delegate: PostPurchaseScriptCallbackDelegate?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            let messageString = message.body as? String,
            let messageData = messageString.data(using: .utf8) else {
                delegate?.onError(message: "Can not parse web message", error: nil)
                return
        }

        do {
            let callbackMessage = try JSONDecoder().decode(PPECallbackMessage.self, from: messageData)
            switch callbackMessage.action {
            case "onInitialize":
                let error = callbackMessage.message.jsValue()
                let success = error == nil
                delegate?.onInitialized(success: success, error: error)
            case "onRenderOperation":
                guard let resultDict = callbackMessage.messageDictionary() else {
                    delegate?.onRenderOperation(success: false, data: nil, error: nil)
                    return
                }
                let resultData = (resultDict["data"] as? String).jsValue()
                let resultError = (resultDict["error"] as? String).jsValue()
                let success = resultError == nil
                
                delegate?.onRenderOperation(success: success, data: resultData, error: resultError)
            case "onAuthorizationRequest":
                let error = callbackMessage.message.jsValue()
                let success = error == nil
                delegate?.onAuthorizationRequest(success: success, error: error)
            default:
                delegate?.onError(message: "No handler for action \(callbackMessage.action ?? "null")", error: nil)
            }

        } catch let error {
            delegate?.onError(message: "Cannot process message: \(messageString)", error: error)
        }
    }
    
    struct PPECallbackMessage: Codable {
        var action: String?
        var message: String?
        
        func messageData() -> Data? {
            return message?.data(using: .utf8)
        }
        
        func messageDictionary() -> [String: Any]? {
            if let data = messageData() {
                return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }
            return nil
        }
    }
}
