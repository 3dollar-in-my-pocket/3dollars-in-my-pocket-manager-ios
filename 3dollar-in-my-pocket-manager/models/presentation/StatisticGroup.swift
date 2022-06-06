struct StatisticGroup: Equatable {
    let date: String
    let feedbacks: [Statistic]
    
    init(response: BossStoreFeedbackGroupingDateResponse) {
        self.date = response.date
        self.feedbacks = response.feedbacks.map(Statistic.init(response:))
    }
}
