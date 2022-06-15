import Foundation

struct FeedbackType: Equatable {
    let description: String
    let emoji: String
    let feedbackType: String
    
    init(response: BossStoreFeedbackTypeResponse) {
        self.description = response.description
        self.emoji = response.emoji
        self.feedbackType = response.feedbackType
    }
    
    init() {
        self.description = ""
        self.emoji = ""
        self.feedbackType = ""
    }
}
