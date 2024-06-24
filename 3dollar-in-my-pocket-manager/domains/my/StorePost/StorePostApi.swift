import Alamofire

enum StorePostApi {
    case fetchPostList(storeId: String, size: Int, cursor: String?)
    case uploadPost(storeId: String, input: PostCreateApiRequest)
    case deletePost(storeId: String, postId: String)
    case editPost(storeId: String, postId: String, input: PostCreateApiRequest)
}

extension StorePostApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchPostList(let storeId, _, _):
            return "/v1/store/\(storeId)/news-posts"
        case .uploadPost(let storeId, _):
            return "/v1/store/\(storeId)/news-post"
        case .deletePost(let storeId, let postId):
            return "/v1/store/\(storeId)/news-post/\(postId)"
        case .editPost(let storeId, let postId, let input):
            return "/v1/store/\(storeId)/news-post/\(postId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchPostList:
            return .get
        case .uploadPost:
            return .post
        case .deletePost:
            return .delete
        case .editPost:
            return .patch
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
        case .deletePost:
            return nil
        case .editPost(_, _, let input):
            return input.toDictionary
        }
    }
}
