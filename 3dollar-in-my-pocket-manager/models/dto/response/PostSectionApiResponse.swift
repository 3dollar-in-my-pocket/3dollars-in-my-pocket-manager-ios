import Foundation

struct PostSectionApiResponse: Decodable, Hashable {
    let sectionType: PostSectionType
    let url: String
    let ratio: Double
}

enum PostSectionType: String, Decodable {
    case image = "IMAGE"
    case unknown
    
    init(from decoder: Decoder) throws {
        self = try PostSectionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
