import Alamofire

enum UserApi {
    case fetchUser
}

extension UserApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchUser:
            return "/v1/boss/account/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchUser:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchUser:
            return nil
        }
    }
}
