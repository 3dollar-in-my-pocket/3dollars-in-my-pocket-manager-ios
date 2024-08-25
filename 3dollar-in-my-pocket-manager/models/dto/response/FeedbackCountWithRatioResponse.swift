struct FeedbackCountWithRatioResponse: Decodable {
    let count: Int
    let feedbackType: String
    let ratio: Double
}
