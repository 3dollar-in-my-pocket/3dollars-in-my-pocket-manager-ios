//struct Statistic: Equatable, Comparable {
//    let type: FeedbackType
//    let count: Int
//    let ratio: Double
//    
//    init(response: FeedbackCountWithRatioResponse) {
//        self.type = SharedContext.shared.getFeedbackType(by: response.feedbackType)
//        self.count = response.count
//        self.ratio = response.ratio
//    }
//    
//    init(response: FeedbackCountResponse) {
//        self.type = SharedContext.shared.getFeedbackType(by: response.feedbackType)
//        self.count = response.count
//        self.ratio = 0
//    }
//    
//    static func < (lhs: Statistic, rhs: Statistic) -> Bool {
//        return lhs.count > rhs.count
//    }
//}
