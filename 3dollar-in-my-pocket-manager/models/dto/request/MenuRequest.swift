import Foundation

struct MenuRequest: Encodable {
    let groupName: String
    let imageUrl: String?
    let name: String
    let price: Int?
    
    enum CodingKeys: String, CodingKey {
        case groupName
        case imageUrl
        case name
        case price
    }
    
    init(menu: Menu) {
        self.groupName = ""
        self.imageUrl = menu.imageUrl
        self.name = menu.name
        self.price = menu.price
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.groupName, forKey: .groupName)
        try container.encodeIfPresent(self.imageUrl, forKey: .imageUrl)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.price, forKey: .price)
    }
}
