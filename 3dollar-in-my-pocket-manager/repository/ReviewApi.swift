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
    case createCommentToReview(nonceToken: String, storeId: String, reviewId: String, input: CommentCreateRequest)
    case reportReview(storeId: String, reviewId: String, input: ReportCreateRequest)
    case deleteReviewComment(storeId: String, reviewId: String, commentId: String)
    case fetchCommentPreset(storeId: String)
    case addCommentPreset(nonceToken: String, storeId: String, input: CommentPresetCreateRequest)
    case editCommentPreset(storeId: String, presetId: String, input: CommentPresetPatchRequest)
    case deleteCommentPreset(storeId: String, presetId: String)
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
        case .createCommentToReview(_, let storeId, let reviewId, _):
            return "/v1/store/\(storeId)/review/\(reviewId)/comment"
        case .reportReview(let storeId, let reviewId, _):
            return "/v1/store/\(storeId)/review/\(reviewId)/report"
        case .deleteReviewComment(let storeId, let reviewId, let commentId):
            return "/v1/store/\(storeId)/review/\(reviewId)/comment/\(commentId)"
        case .fetchCommentPreset(let storeId):
            return "/v1/store/\(storeId)/comment-presets"
        case .addCommentPreset(_, let storeId, _):
            return "/v1/store/\(storeId)/comment-preset"
        case .editCommentPreset(let storeId, let presetId, _):
            return "/v1/store/\(storeId)/comment-preset/\(presetId)"
        case .deleteCommentPreset(let storeId, let presetId):
            return "/v1/store/\(storeId)/comment-preset/\(presetId)"
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
        case .reportReview:
            return .post
        case .deleteReviewComment:
            return .delete
        case .fetchCommentPreset:
            return .get
        case .addCommentPreset:
            return .post
        case .editCommentPreset:
            return .patch
        case .deleteCommentPreset:
            return .delete
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
        case .createCommentToReview(_, _, _, let input):
            return input.toDictionary
        case .reportReview(_, _, let input):
            return input.toDictionary
        case .deleteReviewComment:
            return nil
        case .fetchCommentPreset:
            return ["size": 20]
        case .addCommentPreset(_, _, let input):
            return input.toDictionary
        case .editCommentPreset(_, _, let input):
            return input.toDictionary
        case .deleteCommentPreset:
            return nil
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .createCommentToReview(let nonceToken, _, _, _):
            var header = HTTPUtils.defaultHeader()
            header.add(HTTPHeader(name: "X-Nonce-Token", value: nonceToken))
            return header
        case .addCommentPreset(let nonceToken, _, _):
            var header = HTTPUtils.defaultHeader()
            header.add(HTTPHeader(name: "X-Nonce-Token", value: nonceToken))
            return header
        default:
            return HTTPUtils.defaultHeader()
        }
    }
}
