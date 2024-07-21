//
//  Context.swift
//  3dollar-in-my-pocket-manager
//
//  Created by Hyun Sik Yoo on 2022/06/15.
//

import Foundation

final class SharedContext {
    static let shared = SharedContext()
    
    var feedbackTypes: [FeedbackType] = []
    
    func getFeedbackType(by type: String) -> FeedbackType {
        if let feedbackType = self.feedbackTypes.first(where: { $0.feedbackType == type }) {
            return feedbackType
        } else {
            return FeedbackType()
        }
    }
}
