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
    let stickers: [StickerResponse]
    let createdAt: String
    let updatedAt: String
}

extension StorePostApiResponse {
    var likeCount: Int {
        stickers.first?.count ?? 0
    }
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

struct StickerResponse: Decodable, Hashable {
    let stickerId: String
    let emoji: String
    let count: Int
    let reactedByMe: Bool
}
