import Foundation

struct LoginResponse: Decodable {
    let bossId: String
    let token: String
    
    enum CodingKeys: String, CodingKey {
      case bossId
      case token
    }
    
    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      
      self.bossId = try values.decodeIfPresent(String.self, forKey: .bossId) ?? ""
      self.token = try values.decodeIfPresent(String.self, forKey: .token) ?? ""
    }
}
