struct FAQ {
    let answer: String
    let category: String
    let faqId: Int
    let question: String
    
    init(response: FAQResponse) {
        self.answer = response.answer
        self.category = response.categoryInfo.description
        self.faqId = response.faqId
        self.question = response.question
    }
}

extension FAQ: Comparable {
    static func < (lhs: FAQ, rhs: FAQ) -> Bool {
        return lhs.faqId == rhs.faqId
    }
}
