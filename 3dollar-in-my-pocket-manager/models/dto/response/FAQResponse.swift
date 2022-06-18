struct FAQResponse: Decodable {
    let answer: String
    let category: String
    let faqId: Int
    let question: String
    
    enum CodingKeys: String, CodingKey {
        case answer
        case category
        case faqId
        case question
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.answer = try values.decodeIfPresent(String.self, forKey: .answer) ?? ""
        self.category = try values.decodeIfPresent(String.self, forKey: .category) ?? ""
        self.faqId = try values.decodeIfPresent(Int.self, forKey: .faqId) ?? 0
        self.question = try values.decodeIfPresent(String.self, forKey: .question) ?? ""
    }
}
