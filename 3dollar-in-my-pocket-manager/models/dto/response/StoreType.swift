import Foundation

enum StoreType: String, Decodable {
    case userStore = "USER_STORE"
    case bossStore = "BOSS_STORE"
    case unknown
    
    init(from decoder: Decoder) throws {
        self = try StoreType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
