import Foundation

extension String {
    func jsScriptString() -> String {
        return "'\(self)'"
    }
}

extension Optional where Wrapped == String {
    func jsScriptString() -> String {
        if let it = self {
            return "'\(it)'"
        } else {
            return "null"
        }
    }
}
