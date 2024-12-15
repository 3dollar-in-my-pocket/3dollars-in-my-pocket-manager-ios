import Foundation
import UIKit

enum SocialType: String, Decodable {
    case apple = "APPLE"
    case kakao = "KAKAO"
    case google = "GOOGLE"
    case unknown
    
    init(from decoder: any Decoder) throws {
        self = try SocialType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    var iconImage: UIImage? {
        switch self {
        case .apple:
            return UIImage(named: "ic_apple_logo")
        case .kakao:
            return UIImage(named: "ic_kakao_logo")
        case .google:
            return UIImage(named: "ic_kakao_logo")
        case .unknown:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .apple:
            return "애플"
        case .kakao:
            return "카카오"
        case .google:
            return "구글"
        case .unknown:
            return ""
        }
    }
}
