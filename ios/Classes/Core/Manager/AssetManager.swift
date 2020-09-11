import Foundation

class AssetManager {
    
    static func readAsset(fileName: String, fileExtension: String) -> String? {
        if let path = Bundle(for: AssetManager.self).url(forResource: fileName, withExtension: fileExtension) {
            let text = try? String.init(contentsOf: path, encoding: String.Encoding.utf8)
            return text
        } else {
            ErrorCallbackHandler.instance.sendValue(value: "Failed to read from assets, asset: \(fileName).\(fileExtension)")
        }
        return nil
    }
}
