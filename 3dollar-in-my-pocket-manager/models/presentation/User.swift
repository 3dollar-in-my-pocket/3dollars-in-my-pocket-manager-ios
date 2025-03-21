import Foundation

struct User: Equatable {
    let bossId: String
    let businessNumber: String
    let name: String
    let socialType: SocialType
    var isNotificationEnable: Bool
    
    init(response: BossWithSettingsResponse) {
        self.bossId = response.bossId
        self.businessNumber = response.businessNumber
        self.name = response.name
        self.isNotificationEnable = response.settings.enableActivitiesPush
        self.socialType = response.socialType
    }
    
    init(
        bossId: String = "",
        businessNumber: String = "",
        name: String = "",
        socialType: SocialType = .kakao,
        isNotificationEnable: Bool = true
    ) {
        self.bossId = bossId
        self.businessNumber = businessNumber
        self.name = name
        self.socialType = socialType
        self.isNotificationEnable = isNotificationEnable
    }
}
