import Foundation

struct CommentResponse: Decodable, Hashable {
    let commentId: String
    let content: String
    let status: CommentStatus
    let isOwner: Bool
    let createdAt: String
    let updatedAt: String
}

struct ContentListCommentResponse: Decodable, Hashable {
    var contents: [CommentResponse]
}

enum CommentStatus: String, Decodable {
    case active = "ACTIVE"
    case blinded = "BLINDED"
    case deleted = "DELETED"
    case unknown
    
    init(from decoder: any Decoder) throws {
        self = try CommentStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
