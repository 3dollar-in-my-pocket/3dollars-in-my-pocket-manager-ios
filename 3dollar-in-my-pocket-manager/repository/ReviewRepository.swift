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
    
    func fetchReview(storeId: String, reviewId: String) async -> ApiResult<StoreReviewResponse>
    
    func createCommentToReview(storeId: String, reviewId: String, input: CommentCreateRequest) async -> ApiResult<CommentCreateResponse>
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
    
    func fetchReview(storeId: String, reviewId: String) async -> ApiResult<StoreReviewResponse> {
        return await ReviewApi.fetchReview(storeId: storeId, reviewId: reviewId).asyncRequest()
    }
    
    func createCommentToReview(storeId: String, reviewId: String, input: CommentCreateRequest) async -> ApiResult<CommentCreateResponse> {
        return await ReviewApi.createCommentToReview(storeId: storeId, reviewId: reviewId, input: input).asyncRequest()
    }
}
