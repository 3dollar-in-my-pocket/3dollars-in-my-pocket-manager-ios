struct FAQ {
    let answer: String
    let category: String
    let faqId: Int
    let question: String
    
    init(response: FAQResponse) {
        self.answer = response.answer
        self.category = response.category
        self.faqId = response.faqId
        self.question = response.question
    }
}
