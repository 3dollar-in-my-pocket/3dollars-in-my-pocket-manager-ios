struct CursorResponse: Decodable {
    let hasMore: Bool
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case hasMore
        case nextCursor
    }
    
    init() {
        self.hasMore = false
        self.nextCursor = nil
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.hasMore = try values.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
        self.nextCursor = try values.decodeIfPresent(
            String.self,
            forKey: .nextCursor
        )
    }
}
