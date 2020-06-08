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
}
