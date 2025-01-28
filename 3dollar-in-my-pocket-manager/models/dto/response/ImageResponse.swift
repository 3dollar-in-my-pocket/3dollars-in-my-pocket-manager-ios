import Foundation

struct ImageResponse: Decodable, Hashable {
    let imageUrl: String
    let width: Int?
    let height: Int?
}
