struct BossStoreMenu: Hashable {
    var image: BossStoreImage?
    var name: String
    var price: Int
    
    init(
        image: BossStoreImage? = nil,
        name: String = "",
        price: Int = 0
    ) {
        self.image = image
        self.name = name
        self.price = price
    }
    
    enum CodingKeys: String, CodingKey {
        case imageUrl
        case name
        case price
    }
}

// MARK: BossStoreMenuRequest
extension BossStoreMenu: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl)
        self.image = BossStoreImage(imageUrl: imageUrl)
        self.name = try values.decode(String.self, forKey: .name)
        self.price = try values.decode(Int.self, forKey: .price)
    }
}

// MARK: BossStoreMenuResponse
extension BossStoreMenu: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let imageUrl = image?.imageUrl {
            try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        }
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
    }
}
