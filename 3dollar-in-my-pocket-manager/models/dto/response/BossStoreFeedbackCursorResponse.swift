struct BossStoreFeedbackCursorResponse: Decodable {
    let contents: [BossStoreFeedbackGroupingDateResponse]
    let cursor: CursorResponse
    
    enum CodingKeys: String, CodingKey {
        case contents
        case cursor
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.contents = try values.decodeIfPresent(
            [BossStoreFeedbackGroupingDateResponse].self,
            forKey: .contents
        ) ?? []
        self.cursor = try values.decodeIfPresent(
            CursorResponse.self,
            forKey: .cursor
        ) ?? CursorResponse()
    }
}
