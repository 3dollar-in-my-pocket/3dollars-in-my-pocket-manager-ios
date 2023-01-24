import Foundation

struct JsonUtils {
    static func decode<T: Decodable>(object: Any) -> T? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: object) {
            let decoder = JSONDecoder()
            let result = try? decoder.decode(T.self, from: jsonData)
            
            return result
        } else {
            return nil
        }
    }
    
    static func decode<T: Decodable>(data: Data?) -> T? {
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        let result = try? decoder.decode(T.self, from: data)
        
        return result
    }
}
