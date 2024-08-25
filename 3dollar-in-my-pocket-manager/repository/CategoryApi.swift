import Alamofire

enum CategoryApi {
    case fetchCategories
}

extension CategoryApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchCategories:
            return "/v1/boss/store/categories"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchCategories:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchCategories:
            return nil
        }
    }
}
