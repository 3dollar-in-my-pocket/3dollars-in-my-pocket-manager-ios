import Foundation

struct CommentCreateRequest: Encodable {
    let content: String
}

struct CommentPresetCreateRequest: Encodable {
    let body: String
}

struct CommentPresetPatchRequest: Encodable {
    let body: String
}
