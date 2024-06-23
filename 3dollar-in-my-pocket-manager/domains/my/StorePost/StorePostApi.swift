import Alamofire

enum StorePostApi {
    case fetchPostList(storeId: String, size: Int, cursor: String?)
    case uploadPost(storeId: String, input: PostCreateApiRequest)
}

extension StorePostApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchPostList(let storeId, _, _):
            return "/v1/store/\(storeId)/news-posts"
        case .uploadPost(let storeId, _):
            return "/v1/store/\(storeId)/news-post"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchPostList:
            return .get
        case .uploadPost:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchPostList(_, let size, let cursor):
            var parameters: Parameters = ["size": size]
            
            if let cursor {
                parameters["cursor"] = cursor
            }
            
            return parameters
        case .uploadPost(_, let input):
            return input.toDictionary
        }
    }
}
