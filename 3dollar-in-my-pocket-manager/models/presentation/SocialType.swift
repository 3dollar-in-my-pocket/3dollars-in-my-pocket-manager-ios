import Foundation
import UIKit

enum SocialType: String, Decodable {
    case apple = "APPLE"
    case kakao = "KAKAO"
    case google = "GOOGLE"
    
    var iconImage: UIImage? {
        switch self {
        case .apple:
            return UIImage(named: "ic_kakao_logo")
            
        case .kakao:
            return UIImage(named: "ic_kakao_logo")
            
        case .google:
            return UIImage(named: "ic_kakao_logo")
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
        }
    }
}
