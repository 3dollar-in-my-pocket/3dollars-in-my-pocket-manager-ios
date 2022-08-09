struct FAQCategoryResponse: Decodable {
    let category: String
    let description: String
    let displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case category
        case description
        case displayOrder
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.category = try values.decodeIfPresent(String.self, forKey: .category) ?? ""
        self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.displayOrder = try values.decodeIfPresent(Int.self, forKey: .displayOrder) ?? 0
    }
    
    init() {
        self.category = ""
        self.description = ""
        self.displayOrder = 1
    }
}
