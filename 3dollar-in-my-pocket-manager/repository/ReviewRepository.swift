import Alamofire

protocol ReviewRepository {
    func fetchReviews(
        storeId: String,
        sort: ReviewSortType?,
        cursor: String?,
        size: Int?
    ) async -> ApiResult<ContentListWithCursor<StoreReviewResponse>>
    func toggleLikeReview(
        storeId: String,
        reviewId: String,
        input: StickersReplaceRequest
    ) async -> ApiResult<String>
}

final class ReviewRepositoryImpl: ReviewRepository {
    func fetchReviews(storeId: String, sort: ReviewSortType?, cursor: String?, size: Int?) async -> ApiResult<ContentListWithCursor<StoreReviewResponse>> {
        return await ReviewApi.fetchReviews(
            storeId: storeId,
            sort: sort,
            cursor: cursor,
            size: size
        ).asyncRequest()
    }
    
    func toggleLikeReview(
        storeId: String,
        reviewId: String,
        input: StickersReplaceRequest
    ) async -> ApiResult<String> {
        return await ReviewApi.toggleLikeReview(storeId: storeId, reviewId: reviewId, input: input).asyncRequest()
    }
}
