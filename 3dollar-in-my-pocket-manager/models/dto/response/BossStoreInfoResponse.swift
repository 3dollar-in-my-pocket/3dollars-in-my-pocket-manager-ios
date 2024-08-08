struct BossStoreInfoResponse: Decodable, Hashable {
    let appearanceDays: [BossStoreAppearanceDayResponse]
    let bossStoreId: String
    let categories: [StoreCategoryResponse]
    let createdAt: String?
    let distance: Int
    let imageUrl: String?
    let introduction: String?
    var location: LocationResponse?
    let menus: [BossStoreMenuResponse]
    let name: String
    var openStatus: BossStoreOpenStatusResponse
    let snsUrl: String?
    let updatedAt: String?
    let accountNumbers: [StoreAccountNumberResponse]
}
