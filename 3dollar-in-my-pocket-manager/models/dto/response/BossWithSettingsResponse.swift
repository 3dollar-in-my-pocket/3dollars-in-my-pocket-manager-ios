import Foundation

struct BossWithSettingsResponse: Decodable {
    let bossId: String
    let socialType: SocialType
    let name: String
    let businessNumber: String
    let settings: BossSettingResponse
    let createdAt: String
    let updatedAt: String
}

struct BossSettingResponse: Decodable {
    let enableActivitiesPush: Bool
}
