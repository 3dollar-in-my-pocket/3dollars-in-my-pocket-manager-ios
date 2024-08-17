struct BossStoreMenu: Codable, Hashable {
    let imageUrl: String?
    let name: String
    let price: Int
    
    init(
        imageUrl: String = "",
        name: String = "",
        price: Int = 0
    ) {
        self.imageUrl = imageUrl
        self.name = name
        self.price = price
    }
}
