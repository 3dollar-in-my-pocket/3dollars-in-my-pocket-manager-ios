import Alamofire

enum ReviewSortType: String {
    case latest = "LATEST"
    case highestRating = "HIGHEST_RATING"
    case lowestRating = "LOWEST_RATING"
}

enum ReviewApi {
    case fetchReviews(
        storeId: String,
        sort: ReviewSortType?,
        cursor: String?,
        size: Int?
    )
    case toggleLikeReview(storeId: String, reviewId: String, input: StickersReplaceRequest)
    case fetchReview(storeId: String, reviewId: String)
    case createCommentToReview(storeId: String, reviewId: String, input: CommentCreateRequest)
}

extension ReviewApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchReviews(let storeId, _, _, _):
            return "/v1/store/\(storeId)/reviews"
        case .toggleLikeReview(let storeId, let reviewId, _):
            return "/v1/store/\(storeId)/review/\(reviewId)/stickers"
        case .fetchReview(let storeId, let reviewId):
            return "/v1/store/\(storeId)/review/\(reviewId)"
        case .createCommentToReview(let storeId, let reviewId, let input):
            return "/v1/store/\(storeId)/review/\(reviewId)/comment"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchReviews:
            return .get
        case .toggleLikeReview:
            return .put
        case .fetchReview:
            return .get
        case .createCommentToReview:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchReviews(_, let sort, let cursor, let size):
            var parameters: Parameters = [:]
            
            if let sort = sort {
                parameters["sort"] = sort.rawValue
            }
            
            if let cursor = cursor {
                parameters["cursor"] = cursor
            }
            
            if let size = size {
                parameters["size"] = size
            }
            
            return parameters
        case .toggleLikeReview(_, _, let input):
            return input.toDictionary
        case .fetchReview:
            return nil
        case .createCommentToReview(_, _, let input):
            return input.toDictionary
        }
    }
}
