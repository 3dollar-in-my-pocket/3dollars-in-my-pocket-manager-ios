struct FeedbackGroupingDateResponse: Decodable {
    let date: String
    let feedbacks: [FeedbackCountResponse]
}
