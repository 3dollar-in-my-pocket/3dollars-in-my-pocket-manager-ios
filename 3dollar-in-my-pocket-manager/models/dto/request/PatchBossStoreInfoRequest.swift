import Foundation

struct PatchBossStoreInfoRequest: Encodable {
    let appearanceDays: [AppearanceDayRequest]?
    let categoriesIds: [String]?
    let imageUrl: String?
    let introduction: String?
    let menus: [MenuRequest]?
    let name: String?
    let snsUrl: String?
    let accountNumbers: BossStoreAccountNumberApiRequest?
    
    enum CodingKeys: String, CodingKey {
        case appearanceDays
        case categoriesIds
        case imageUrl
        case introduction
        case menus
        case name
        case snsUrl
        case accountNumbers
    }
    
    init(
        appearanceDays: [AppearanceDayRequest]? = nil,
        categoriesIds: [String]? = nil,
        imageUrl: String? = nil,
        introduction: String? = nil,
        menus: [MenuRequest]? = nil,
        name: String? = nil,
        snsUrl: String? = nil,
        accountNumbers: BossStoreAccountNumberApiRequest? = nil
    ) {
        self.appearanceDays = appearanceDays
        self.categoriesIds = categoriesIds
        self.imageUrl = imageUrl
        self.introduction = introduction
        self.menus = menus
        self.name = name
        self.snsUrl = snsUrl
        self.accountNumbers = accountNumbers
    }
    
    init(store: Store) {
        self.appearanceDays = store.appearanceDays.map(AppearanceDayRequest.init)
        self.categoriesIds = store.categories.map { $0.categoryId }
        self.imageUrl = store.imageUrl
        self.introduction = store.introduction
        self.menus = store.menus.map(MenuRequest.init(menu:))
        self.name = store.name
        self.snsUrl = store.snsUrl
        self.accountNumbers = BossStoreAccountNumberApiRequest(store.accountInfo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.appearanceDays, forKey: .appearanceDays)
        try container.encodeIfPresent(self.categoriesIds, forKey: .categoriesIds)
        try container.encodeIfPresent(self.imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(self.introduction, forKey: .introduction)
        try container.encodeIfPresent(self.menus, forKey: .menus)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.snsUrl, forKey: .snsUrl)
        try container.encodeIfPresent(self.accountNumbers, forKey: .accountNumbers)
    }
}
