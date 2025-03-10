struct FeedbackTypeResponse: Decodable {
    let description: String
    let emoji: String
    let feedbackType: String
}

extension Array where Element == FeedbackTypeResponse {
    subscript(feedbackType: String) -> FeedbackTypeResponse? {
        return self.first { $0.feedbackType == feedbackType }
    }
}
