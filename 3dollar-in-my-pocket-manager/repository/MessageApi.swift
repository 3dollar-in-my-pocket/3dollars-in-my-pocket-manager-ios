import Alamofire

enum MessageApi {
    case sendMessage(input: StoreMessageCreateRequest)
}

extension MessageApi: ApiRequest {
    var path: String {
        switch self {
        case .sendMessage(let input):
            return "/v1/store/\(input.storeId)/message"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .sendMessage:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .sendMessage(let input):
            return input.toDictionary
        }
    }
}
