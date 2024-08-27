struct BossStoreSimpleResponse: Decodable {
    let bossStoreId: String
    let isOwner: Bool
    let name: String
    let location: LocationResponse?
    let address: AddressResponse
    let menus: [BossStoreMenu]
    let categories: [StoreCategoryResponse]
    let openStatus: BossStoreOpenStatusResponse
    let distance: Int
    let createdAt: String?
    let updatedAt: String?
}
