import Alamofire

enum SharedApi {
    case nonce(input: NonceCreateRequest)
}

extension SharedApi: ApiRequest {
    var path: String {
        switch self {
        case .nonce:
            return "/v1/nonce"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .nonce(let input):
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .nonce(let input):
            return input.toDictionary
        }
    }
}
