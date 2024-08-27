struct FeedbackTypeResponse: Decodable {
    let description: String
    let emoji: String
    let feedbackType: String
}


struct FeedbackCountWithRatioResponse: Decodable {
    let feedbackType: String
    let count: Int
    let ratio: Double
}

struct FeedbackCountListResponse: Decodable {
    let targetId: String
    let date: String
    let feedbacks: [FeedbackCountResponse]
}

struct FeedbackCountResponse: Decodable {
    let feedbackType: String
    let count: Int
}
