import Foundation

struct StoreReviewResponse: Decodable, Hashable {
    let reviewId: String
    let rating: Int
    let contents: String?
    let images: [ImageResponse]
    let status: StoreReviewStatus
    let writer: UserResponse
    var stickers: [StickerResponse]
    var comments: ContentListCommentResponse
    let createdAt: String
    let updatedAt: String
}

enum StoreReviewStatus: String, Decodable {
    case posted = "POSTED"
    case filtered = "FILTERED"
    case deleted = "DELETED"
    case unknown
    
    init(from decoder: any Decoder) throws {
        self = try StoreReviewStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
