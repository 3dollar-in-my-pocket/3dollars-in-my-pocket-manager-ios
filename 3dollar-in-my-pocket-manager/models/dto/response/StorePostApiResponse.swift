import Foundation

struct StorePostApiResponse: Decodable {
    let postId: String
    var body: String
    var sections: [PostSectionApiResponse]
    let isOwner: Bool
    let store: StoreApiResponse
    let createdAt: String
    let updatedAt: String
}
