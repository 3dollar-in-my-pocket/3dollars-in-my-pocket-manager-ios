import Foundation

struct MedalResponse: Decodable, Hashable {
    let medalId: Int64?
    let name: String
    let iconUrl: String?
    let disableIconUrl: String?
    let createdAt: String?
    let updatedAt: String?
}
