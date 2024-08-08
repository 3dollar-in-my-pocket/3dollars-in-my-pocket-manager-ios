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
