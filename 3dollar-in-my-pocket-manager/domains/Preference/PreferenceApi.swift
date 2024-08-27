import Alamofire

enum PreferenceApi {
    case fetchPreference(storeId: String)
    case updatePreference(
        storeId: String,
        storePreferencePatchRequest: StorePreferencePatchRequest
    )
}

extension PreferenceApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchPreference(let storeId):
            return "/v1/store/\(storeId)/preference"
        case .updatePreference(let storeId, _):
            return "/v1/store/\(storeId)/preference"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchPreference:
            return .get
        case .updatePreference:
            return .patch
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchPreference:
            return nil
        case .updatePreference(_, let storePreferencePatchRequest):
            return storePreferencePatchRequest.toDictionary()
        }
    }
}
