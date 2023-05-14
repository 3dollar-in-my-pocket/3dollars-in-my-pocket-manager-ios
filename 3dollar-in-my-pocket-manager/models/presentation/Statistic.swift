struct Statistic: Equatable, Comparable {
    let type: FeedbackType
    let count: Int
    let ratio: Double
    
    init(response: BossStoreFeedbackCountResponse) {
        self.type = Context.shared.getFeedbackType(by: response.feedbackType)
        self.count = response.count
        self.ratio = response.ratio
    }
    
    static func < (lhs: Statistic, rhs: Statistic) -> Bool {
        return lhs.count > rhs.count
    }
}
