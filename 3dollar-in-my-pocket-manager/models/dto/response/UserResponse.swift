import Foundation

struct UserResponse: Decodable, Hashable {
    let userId: Int64?
    let name: String
    let socialType: SocialType?
    let medal: MedalResponse
}
