struct FeedbackCountWithRatioResponse: Decodable, Hashable {
    let count: Int
    let feedbackType: String
    let ratio: Double
}
