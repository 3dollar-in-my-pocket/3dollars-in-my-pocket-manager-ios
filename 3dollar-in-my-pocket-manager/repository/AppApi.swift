import Alamofire

enum AppApi {
    case fetchAppStatus
}

extension AppApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchAppStatus:
            return "/v1/app/status"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchAppStatus:
            return .get
        }
    }

    var parameters: Parameters? {
        switch self {
        case .fetchAppStatus:
            return nil
        }
    }
}
