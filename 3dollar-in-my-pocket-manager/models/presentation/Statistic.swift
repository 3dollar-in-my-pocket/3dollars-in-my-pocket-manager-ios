struct Statistic: Equatable {
    let type: FeedbackType
    let count: Int
    let ratio: Double
    
    init(response: BossStoreFeedbackCountResponse) {
        self.type = response.feedbackType
        self.count = response.count
        self.ratio = response.ratio
    }
}
