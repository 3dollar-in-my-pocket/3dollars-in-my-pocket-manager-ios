import Foundation

struct CommentPresetResponse: Decodable, Hashable {
    let presetId: String
    let body: String
    let createdAt: String?
    let updatedAt: String?
}
