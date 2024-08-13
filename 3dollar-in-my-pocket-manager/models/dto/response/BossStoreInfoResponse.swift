struct BossStoreInfoResponse: Decodable, Hashable {
    let bossStoreId: String
    let isOwner: Bool
    var name: String
    var location: LocationResponse?
    let address: AddressResponse
    let representativeImages: [ImageResponse]
    let introduction: String?
    var snsUrl: String?
    let menus: [BossStoreMenuResponse]
    let appearanceDays: [BossStoreAppearanceDayResponse]
    var categories: [StoreFoodCategoryResponse]
    let accountNumbers: [StoreAccountNumberResponse]
    var openStatus: BossStoreOpenStatusResponse
    let distance: Int
    let favorite: StoreFavoriteResponse
    let createdAt: String?
    let updatedAt: String?
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


struct StoreAccountNumberResponse: Decodable, Hashable {
    let bank: BankResponse
    let accountHolder: String
    let accountNumber: String
    let description: String?
}

struct BankResponse: Decodable, Hashable {
    let key: String
    let description: String
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
