import Foundation

struct BossAccountInfoResponse: Decodable {
    let bossId: String
    let businessNumber: String
    let createdAt: String
    let name: String
    let isSetupNotification: Bool
    let socialType: SocialType
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case bossId
        case businessNumber
        case createdAt
        case name
        case isSetupNotification
        case socialType
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.bossId = try values.decodeIfPresent(String.self, forKey: .bossId) ?? ""
        self.businessNumber = try values.decodeIfPresent(
            String.self,
            forKey: .businessNumber
        ) ?? ""
        self.createdAt = try values.decodeIfPresent(
            String.self,
            forKey: .createdAt
        ) ?? ""
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.isSetupNotification = try values.decodeIfPresent(
            Bool.self,
            forKey: .isSetupNotification
        ) ?? false
        self.socialType = try values.decodeIfPresent(
            SocialType.self,
            forKey: .socialType
        ) ?? .apple
        self.updatedAt = try values.decodeIfPresent(
            String.self,
            forKey: .updatedAt
        ) ?? ""
    }
}
