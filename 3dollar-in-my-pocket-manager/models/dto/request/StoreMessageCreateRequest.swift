import Foundation

struct StoreMessageCreateRequest: Encodable {
    let storeId: String
    let body: String
    
    enum CodingKeys: CodingKey {
        case body
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.body, forKey: .body)
    }
}
