struct FAQResponse: Decodable {
    let answer: String
    let categoryInfo: FAQCategoryResponse
    let faqId: Int
    let question: String
    
    enum CodingKeys: String, CodingKey {
        case answer
        case categoryInfo
        case faqId
        case question
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.answer = try values.decodeIfPresent(String.self, forKey: .answer) ?? ""
        self.categoryInfo = try values.decodeIfPresent(
            FAQCategoryResponse.self,
            forKey: .categoryInfo
        ) ?? FAQCategoryResponse()
        self.faqId = try values.decodeIfPresent(Int.self, forKey: .faqId) ?? 0
        self.question = try values.decodeIfPresent(String.self, forKey: .question) ?? ""
    }
}
