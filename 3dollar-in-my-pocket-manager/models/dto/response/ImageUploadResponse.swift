import Foundation

struct ImageUploadResponse: Decodable {
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
      case imageUrl
    }
    
    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      
      self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
    }
}
