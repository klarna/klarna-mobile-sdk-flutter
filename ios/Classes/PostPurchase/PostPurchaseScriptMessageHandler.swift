import WebKit

internal protocol PostPurchaseScriptCallbackDelegate: class {
    func onInitialize(success: Bool, message: String?, error: String?)
    func onRenderOperation(success: Bool, message: String?, error: String?)
    func onAuthorizationRequest(success: Bool, message: String?, error: String?)
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
            let message = callbackMessage.message.jsValue()
            let error = callbackMessage.error.jsValue()
            let success = error == nil
            switch callbackMessage.action {
            case "onInitialize":
                delegate?.onInitialize(success: success, message: message, error: error)
            case "onRenderOperation":
                delegate?.onRenderOperation(success: success, message: message, error: error)
            case "onAuthorizationRequest":
                delegate?.onAuthorizationRequest(success: success, message: message, error: error)
            default:
                delegate?.onError(message: "No handler for callback message: \(messageString)", error: nil)
            }

        } catch let error {
            delegate?.onError(message: "Cannot process message: \(messageString)", error: error)
        }
    }
    
    struct PPECallbackMessage: Codable {
        var action: String
        var message: String?
        var error: String?
        
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
