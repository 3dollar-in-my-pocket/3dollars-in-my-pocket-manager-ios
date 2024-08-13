struct BossStoreMenuResponse: Decodable, Hashable {
    let groupName: String
    let imageUrl: String
    let name: String
    let price: Int
    
    init(
        groupName: String = "",
        imageUrl: String = "",
        name: String = "",
        price: Int = 0
    ) {
        self.groupName = groupName
        self.imageUrl = imageUrl
        self.name = name
        self.price = price
    }
}

// MARK: BossStoreMenuRequest
extension BossStoreMenuResponse: Encodable {
    enum CodingKeys: String, CodingKey {
        case groupName
        case imageUrl
        case name
        case price
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
    }
}
