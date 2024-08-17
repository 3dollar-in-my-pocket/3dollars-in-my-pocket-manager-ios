import Foundation

struct BossStorePatchRequest: Encodable {
    let name: String?
    let representativeImages: [BossStoreImage]?
    let introduction: String?
    let snsUrl: String?
    let menus: [BossStoreMenu]?
//    let appearanceDays: [BossStoreAppearanceDayRequest]?
    let categoriesIds: [String]?
//    let accountNumbers: BossStoreAccountNumberRequest?
}
