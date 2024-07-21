import Foundation

enum AccountType: String, Decodable {
    case bossAccount = "BOSS_ACCOUNT"
    case userAccount = "USER_ACCOUNT"
    case unknown
    
    init(from decoder: Decoder) throws {
        self = try AccountType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
