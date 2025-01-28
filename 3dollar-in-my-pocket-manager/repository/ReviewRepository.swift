import Alamofire

protocol ReviewRepository {
    func fetchReviews(
        storeId: String,
        sort: ReviewSortType?,
        cursor: String?,
        size: Int?
    ) async throws -> ApiResult<ContentListWithCursor<StoreReviewResponse>>
}

final class ReviewRepositoryImpl: ReviewRepository {
    func fetchReviews(storeId: String, sort: ReviewSortType?, cursor: String?, size: Int?) async throws -> ApiResult<ContentListWithCursor<StoreReviewResponse>> {
        return await ReviewApi.fetchReviews(
            storeId: storeId,
            sort: sort,
            cursor: cursor,
            size: size
        ).asyncRequest()
    }
}
