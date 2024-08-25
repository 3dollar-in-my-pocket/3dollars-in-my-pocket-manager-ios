import Alamofire

enum BankApi {
    case fetchBankList
}

extension BankApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchBankList:
            return "/v1/enums"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchBankList:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchBankList:
            return nil
        }
    }
}
