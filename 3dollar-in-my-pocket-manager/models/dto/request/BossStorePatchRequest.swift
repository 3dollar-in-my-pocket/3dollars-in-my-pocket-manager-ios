import Foundation

struct BossStorePatchRequest: Encodable {
    let name: String?
    let representativeImages: [ImageResponse]?
    let introduction: String?
    let snsUrl: String?
    let menus: [BossStoreMenuResponse]?
//    let appearanceDays: [BossStoreAppearanceDayRequest]?
    let categoriesIds: [String]?
//    let accountNumbers: BossStoreAccountNumberRequest?
}

