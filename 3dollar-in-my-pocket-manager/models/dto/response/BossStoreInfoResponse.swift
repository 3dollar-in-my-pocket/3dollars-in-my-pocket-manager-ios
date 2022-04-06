struct BossStoreInfoResponse: Decodable {
    let appearanceDays: BossStoreAppearanceDayResponse
    let bossStoreId: String
    let categories: [StoreCategoryResponse]
    let contactsNumber: String
    let createdAt: String
    let distance: Int
    let imageUrl: String
    let introduction: String
    let location: LocationResponse
    let menus: [BossStoreMenuResponse]
    let name: String
    let openStatus: BossStoreOpenStatusResponse
    let snsUrl: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case appearanceDays
        case bossStoreId
        case categories
        case contactsNumber
        case createdAt
        case distance
        case imageUrl
        case introduction
        case location
        case menus
        case name
        case openStatus
        case snsUrl
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.appearanceDays = try values.decodeIfPresent(
            BossStoreAppearanceDayResponse.self,
            forKey: .appearanceDays
        ) ?? BossStoreAppearanceDayResponse()
        self.bossStoreId = try values.decodeIfPresent(String.self, forKey: .bossStoreId) ?? ""
        self.categories = try values.decodeIfPresent(
            [StoreCategoryResponse].self,
            forKey: .categories
        ) ?? []
        self.contactsNumber = try values.decodeIfPresent(
            String.self,
            forKey: .contactsNumber
        ) ?? ""
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.introduction = try values.decodeIfPresent(String.self, forKey: .introduction) ?? ""
        self.location = try values.decodeIfPresent(
            LocationResponse.self,
            forKey: .location
        ) ?? LocationResponse()
        self.menus = try values.decodeIfPresent([BossStoreMenuResponse].self, forKey: .menus) ?? []
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.openStatus = try values.decodeIfPresent(
            BossStoreOpenStatusResponse.self,
            forKey: .openStatus
        ) ?? BossStoreOpenStatusResponse()
        self.snsUrl = try values.decodeIfPresent(String.self, forKey: .snsUrl) ?? ""
        self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
    }
}
