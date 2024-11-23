import Foundation

struct StoreMessageResponse: Decodable {
    let messageId: String
    let body: String
    let isOwner: Bool
    let createdAt: String
    let updatedAt: String
}
