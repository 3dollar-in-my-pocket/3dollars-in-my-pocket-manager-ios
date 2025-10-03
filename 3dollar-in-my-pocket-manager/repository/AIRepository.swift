import Alamofire

protocol AIRepository {
    func getRecommendation(storeId: Int, date: String) async -> ApiResult<StoreSalesRecommendationResponse>
}

final class AIRepositoryImpl: AIRepository {
    func getRecommendation(storeId: Int, date: String) async -> ApiResult<StoreSalesRecommendationResponse> {
        return await AIApi.recommend(storeId: storeId, date: date).asyncRequest()
    }
}
