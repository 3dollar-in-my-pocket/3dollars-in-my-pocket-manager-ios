import Foundation

struct StoreFoodCategoryResponse: Decodable {
    let categoryId: String
    let name: String
    let imageUrl: String
    let description: String
    let classification: StoreFoodCategoryClassificationResponse
    let isNew: Bool
}
