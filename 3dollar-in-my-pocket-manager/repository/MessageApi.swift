import Alamofire

enum MessageApi {
    case sendMessage(input: StoreMessageCreateRequest)
    case fetchMessages(storeId: String, cursor: String?)
}

extension MessageApi: ApiRequest {
    var path: String {
        switch self {
        case .sendMessage(let input):
            return "/v1/store/\(input.storeId)/message"
        case .fetchMessages(let storeId, _):
            return "/v1/store/\(storeId)/messages"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .sendMessage:
            return .post
        case .fetchMessages:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .sendMessage(let input):
            return input.toDictionary
        case .fetchMessages(_, let cursor):
            var params: Parameters = ["size": 20]
            if let cursor {
                params["cursor"] = cursor
            }
            return params
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .sendMessage(let input):
            var header = HTTPUtils.defaultHeader()
            header.add(HTTPHeader(name: "X-Nonce-Token", value: input.nonceToken))
            return header
        case .fetchMessages:
            return HTTPUtils.defaultHeader()
        }
    }
}
