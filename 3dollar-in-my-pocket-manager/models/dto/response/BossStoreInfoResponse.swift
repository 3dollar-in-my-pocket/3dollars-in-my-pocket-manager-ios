struct BossStoreResponse: Decodable, Hashable {
    let bossStoreId: String
    let isOwner: Bool
    var name: String
    var location: LocationResponse?
    let address: AddressResponse
    var representativeImages: [BossStoreImage]
    var introduction: String?
    var snsUrl: String?
    var menus: [BossStoreMenu]
    var appearanceDays: [BossStoreAppearanceDayResponse]
    var categories: [StoreFoodCategoryResponse]
    var accountNumbers: [BossStoreAccountNumber]
    var openStatus: BossStoreOpenStatusResponse
    let distance: Int
    let favorite: StoreFavoriteResponse
    let createdAt: String?
    let updatedAt: String?
}

extension BossStoreResponse {
    func toPatchRequest() -> BossStorePatchRequest {
        return BossStorePatchRequest(
            name: name,
            representativeImages: representativeImages,
            introduction: introduction,
            snsUrl: snsUrl,
            menus: nil,
            appearanceDays: appearanceDays.map { .init(response: $0) },
            categoriesIds: categories.map { $0.categoryId },
            accountNumbers: accountNumbers
        )
    }
}

struct LocationResponse: Decodable, Hashable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double = 0, longitude: Double = 0) {
        self.latitude  = latitude
        self.longitude = longitude
    }
}

struct AddressResponse: Decodable, Hashable {
    let fullAddress: String?
}


struct BossStoreAccountNumber: Codable, Hashable {
    var bank: BossBank
    var accountHolder: String
    var accountNumber: String
    let description: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bank.key, forKey: .bank)
        try container.encode(accountHolder, forKey: .accountHolder)
        try container.encode(accountNumber, forKey: .accountNumber)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

struct BossBank: Decodable, Hashable {
    let key: String
    let description: String
    
    init(key: String, description: String) {
        self.key = key
        self.description = description
    }
}


struct BossStoreOpenStatusResponse: Decodable, Hashable {
    var openStartDateTime: String?
    var status: OpenStatus
}

enum OpenStatus: String, Decodable {
    case closed  = "CLOSED"
    case open = "OPEN"
    case unknown
    
    init(from decoder: Decoder) throws {
        self = try OpenStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

struct StoreFavoriteResponse: Decodable, Hashable {
    let subscriberCount: Int
}
