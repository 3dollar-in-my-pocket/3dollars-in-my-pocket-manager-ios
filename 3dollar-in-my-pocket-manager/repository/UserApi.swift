import Alamofire

enum UserApi {
    case fetchUser
    case updateAccountSettings(input: BossSettingPatchRequest)
}

extension UserApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchUser:
            return "/v1/boss/account/me"
        case .updateAccountSettings:
            return "/v1/my/account-settings"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchUser:
            return .get
        case .updateAccountSettings:
            return .patch
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchUser:
            return nil
        case .updateAccountSettings(let input):
            return input.toDictionary
        }
    }
}
