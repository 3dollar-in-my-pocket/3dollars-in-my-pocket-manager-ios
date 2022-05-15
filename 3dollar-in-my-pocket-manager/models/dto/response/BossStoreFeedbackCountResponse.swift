struct BossStoreFeedbackCountResponse: Decodable {
    let count: Int
    let feedbackType: FeedbackType
    
    enum CodingKeys: String, CodingKey {
        case count
        case feedbackType
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.count = try values.decodeIfPresent(Int.self, forKey: .count) ?? 0
        self.feedbackType = try values.decodeIfPresent(
            FeedbackType.self,
            forKey: .feedbackType
        ) ?? .bossIsKind
    }
}
