import Foundation

struct PatchBossStoreInfoRequest: Encodable {
    let appearanceDays: [AppearanceDayRequest]?
    let categoriesIds: [String]?
    let contactsNumber: String?
    let imageUrl: String?
    let introduction: String?
    let menus: [MenuRequest]?
    let name: String?
    let snsUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case appearanceDays
        case categoriesIds
        case contactsNumber
        case imageUrl
        case introduction
        case menus
        case name
        case snsUrl
    }
    
    init(
        appearanceDays: [AppearanceDayRequest]? = nil,
        categoriesIds: [String]? = nil,
        contactsNumber: String? = nil,
        imageUrl: String? = nil,
        introduction: String? = nil,
        menus: [MenuRequest]? = nil,
        name: String? = nil,
        snsUrl: String? = nil
    ) {
        self.appearanceDays = appearanceDays
        self.categoriesIds = categoriesIds
        self.contactsNumber = contactsNumber
        self.imageUrl = imageUrl
        self.introduction = introduction
        self.menus = menus
        self.name = name
        self.snsUrl = snsUrl
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.appearanceDays, forKey: .appearanceDays)
        try container.encodeIfPresent(self.categoriesIds, forKey: .categoriesIds)
        try container.encodeIfPresent(self.contactsNumber, forKey: .contactsNumber)
        try container.encodeIfPresent(self.imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(self.introduction, forKey: .introduction)
        try container.encodeIfPresent(self.menus, forKey: .menus)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.snsUrl, forKey: .snsUrl)
    }
}
