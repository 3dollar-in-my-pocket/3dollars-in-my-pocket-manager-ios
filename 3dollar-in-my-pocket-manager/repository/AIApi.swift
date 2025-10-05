import Alamofire

enum AIApi {
    case recommend(storeId: Int, date: String)
}

extension AIApi: ApiRequest {
    var path: String {
        switch self {
        case .recommend(let storeId, _):
            return "/v1/store/\(storeId)/recommendation"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .recommend:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .recommend(_, let date):
            return ["date": date]
        }
    }
}
