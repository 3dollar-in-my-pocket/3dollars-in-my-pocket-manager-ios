import Foundation

struct User: Equatable {
    let bossId: String
    let businessNumber: String
    let name: String
    let socialType: SocialType
    
    init(response: BossAccountInfoResponse) {
        self.bossId = response.bossId
        self.businessNumber = response.businessNumber
        self.name = response.name
        self.socialType = response.socialType
    }
    
    init(
        bossId: String = "",
        businessNumber: String = "",
        name: String = "",
        socialType: SocialType = .kakao
    ) {
        self.bossId = bossId
        self.businessNumber = businessNumber
        self.name = name
        self.socialType = socialType
    }
}
