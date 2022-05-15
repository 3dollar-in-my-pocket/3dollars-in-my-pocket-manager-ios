struct Statistic {
    let type: FeedbackType
    let count: Int
    
    init(response: BossStoreFeedbackCountResponse) {
        self.type = response.feedbackType
        self.count = response.count
    }
}
