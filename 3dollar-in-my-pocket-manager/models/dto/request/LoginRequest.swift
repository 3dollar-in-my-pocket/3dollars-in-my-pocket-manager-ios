import Foundation

struct LoginRequest: Requestable {
    let socialType: SocialType
    let token: String
    
    var params: [String : Any] {
        return [
            "socialType": socialType.rawValue
        ]
    }
}
