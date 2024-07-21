import Foundation

extension Encodable {
    func toDictionary(
        outputFormatting: JSONEncoder.OutputFormatting = JSONEncoder.OutputFormatting()
    ) -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormatting
        guard let encodedData = try? encoder.encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any] else { return nil }

        return dictionary
    }
    
    var toDictionary: [String: Any] {
        return toDictionary() ?? [:]
    }
}
