import Foundation

import Alamofire

protocol FeedbackRepository {
    func fetchFeedbackType() async -> ApiResult<[FeedbackTypeResponse]>
    
    func fetchTotalStatistics(storeId: String) async -> ApiResult<[FeedbackCountWithRatioResponse]>
    
    func fetchDailyStatistics(
        storeId: String,
        startDate: String,
        endDate: String
    ) async -> ApiResult<ContentListWithCursor<FeedbackGroupingDateResponse>>
}

final class FeedbackRepositoryImpl: FeedbackRepository {
    func fetchFeedbackType() async -> ApiResult<[FeedbackTypeResponse]> {
        return await FeedbackApi.fetchFeedbackType.asyncRequest()
    }
    
    func fetchTotalStatistics(storeId: String) async -> ApiResult<[FeedbackCountWithRatioResponse]> {
        return await FeedbackApi.fetchTotalStatistics(storeId: storeId).asyncRequest()
    }
    
    func fetchDailyStatistics(storeId: String, startDate: String, endDate: String) async -> ApiResult<ContentListWithCursor<FeedbackGroupingDateResponse>> {
        return await FeedbackApi.fetchDailyStatistics(
            storeId: storeId,
            startDate: startDate,
            endDate: endDate
        ).asyncRequest()
    }
}
