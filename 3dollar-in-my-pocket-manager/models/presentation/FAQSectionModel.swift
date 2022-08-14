import RxDataSources

struct FAQSectionModel: Equatable {
    var categoryName: String
    var items: [Item]
}

extension FAQSectionModel: SectionModelType {
    typealias Item = FAQ
    
    init(original: FAQSectionModel, items: [FAQ]) {
        self = original
        self.items = items
    }
    
    init(faqs: [FAQ]) {
        self.categoryName = faqs.first?.category ?? ""
        self.items = faqs
    }
}
