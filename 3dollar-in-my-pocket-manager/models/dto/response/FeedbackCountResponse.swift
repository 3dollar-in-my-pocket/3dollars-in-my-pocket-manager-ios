import Foundation

struct FeedbackCountResponse: Decodable {
    let feedbackType: String
    let count: Int
}
