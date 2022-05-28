struct BossStoreFeedbackGroupingDateResponse: Decodable {
    let date: String
    let feedbacks: [BossStoreFeedbackCountResponse]
    
    enum CodingKeys: String, CodingKey {
        case date
        case feedbacks
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.date = try values.decodeIfPresent(String.self, forKey: .date) ?? ""
        self.feedbacks = try values.decodeIfPresent(
            [BossStoreFeedbackCountResponse].self,
            forKey: .feedbacks
        ) ?? []
    }
}
