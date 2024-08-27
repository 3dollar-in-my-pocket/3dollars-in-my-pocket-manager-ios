import Foundation

struct StoreFoodCategoryResponse: Decodable, Hashable {
    let categoryId: String
    let name: String
    let imageUrl: String
    let description: String
    let classification: StoreFoodCategoryClassificationResponse
    let isNew: Bool
}

struct StoreFoodCategoryClassificationResponse: Decodable, Hashable {
    let type: String
    let description: String
}

