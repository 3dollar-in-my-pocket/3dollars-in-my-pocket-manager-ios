import Alamofire

enum FeedbackApi {
    case fetchFeedbackType
    case fetchTotalStatistics(storeId: String)
    case fetchDailyStatistics(storeId: String, startDate: String, endDate: String)
}

extension FeedbackApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchFeedbackType:
            return "/v1/feedback/STORE/types"
        case .fetchTotalStatistics(let targetId):
            return "/v1/feedback/STORE/target/\(targetId)/full"
        case .fetchDailyStatistics(let targetId, _, _):
            return "/v1/feedback/STORE/target/\(targetId)/specific"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchFeedbackType:
            return .get
        case .fetchTotalStatistics:
            return .get
        case .fetchDailyStatistics:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchFeedbackType:
            return nil
        case .fetchTotalStatistics:
            return nil
        case .fetchDailyStatistics(_, let startDate, let endDate):
            return [
                "startDate": startDate,
                "endDate": endDate
            ]
        }
    }
}
