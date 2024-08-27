import Foundation

struct StorePostListApiResponse: Decodable {
    let contents: [StorePostApiResponse]
    let cursor: CursorString
}

struct StorePostApiResponse: Decodable {
    let postId: String
    var body: String
    var sections: [PostSectionApiResponse]
    let isOwner: Bool
    let store: StoreApiResponse
    let createdAt: String
    let updatedAt: String
}

struct PostSectionApiResponse: Decodable, Hashable {
    let sectionType: PostSectionType
    let url: String
    let ratio: Double
}

enum PostSectionType: String, Codable {
    case image = "IMAGE"
    case unknown
    
    init(from decoder: Decoder) throws {
        self = try PostSectionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

struct PostCreateApiResponse: Decodable {
    let postId: String
}

struct PostCreateApiRequest: Encodable {
    let body: String
    let sections: [PostSectionCreateApiRequest]
}

struct PostSectionCreateApiRequest: Encodable {
    let sectionType: PostSectionType
    let url: String
    let ratio: Double
}
