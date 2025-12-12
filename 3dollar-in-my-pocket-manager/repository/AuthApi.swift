import Alamofire

enum AuthApi {
    case logout(request: BossLogOutRequest?)
}

extension AuthApi: ApiRequest {
    var path: String {
        switch self {
        case .logout:
            return "/v1/auth/logout"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .logout:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .logout(let request):
            return request?.toDictionary()
        }
    }
}
