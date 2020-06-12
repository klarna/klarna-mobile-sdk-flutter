import Foundation

extension String: Error {}

extension String {
    func jsScriptString() -> String {
        return "\"\(self.replacingOccurrences(of: "\"", with: "\\\""))\""
    }
}

extension Optional where Wrapped == String {
    func jsScriptString() -> String {
        if let it = self {
            return it.jsScriptString()
        } else {
            return "null"
        }
    }
    
    func jsIsNullOrUndefined() -> Bool {
        if let value = self {
            return value == "null" || value == "undefined"
        }
        return true
    }
    
    func jsValue() -> String? {
        return self.jsIsNullOrUndefined() ? nil : self
    }
}
