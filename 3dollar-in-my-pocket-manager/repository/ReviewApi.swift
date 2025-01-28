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
}

extension ReviewApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchReviews(let storeId, _, _, _):
            return "/v1/store/\(storeId)/reviews"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchReviews:
            return .get
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
        }
    }
}
