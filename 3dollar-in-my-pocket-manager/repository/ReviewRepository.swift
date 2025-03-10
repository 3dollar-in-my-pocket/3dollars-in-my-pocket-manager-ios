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
    
    func createCommentToReview(
        nonceToken: String,
        storeId: String,
        reviewId: String,
        input: CommentCreateRequest
    ) async -> ApiResult<CommentResponse>
    
    func reportReview(storeId: String, reviewId: String, input: ReportCreateRequest) async -> ApiResult<String>
    
    func deleteReviewComment(storeId: String, reviewId: String, commentId: String) async -> ApiResult<String>
    
    func fetchCommentPresets(storeId: String) async -> ApiResult<ContentListWithCursorAndCount<CommentPresetResponse>>
    
    func addCommentPreset(nonceToken: String, storeId: String, input: CommentPresetCreateRequest) async -> ApiResult<CommentPresetResponse>
    
    func editCommentPreset(storeId: String, commentPresetId: String, input: CommentPresetPatchRequest) async -> ApiResult<String>
    
    func deleteCommentPreset(storeId: String, commentPresetId: String) async -> ApiResult<String>
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
    
    func createCommentToReview(
        nonceToken: String,
        storeId: String,
        reviewId: String,
        input: CommentCreateRequest
    ) async -> ApiResult<CommentResponse> {
        return await ReviewApi.createCommentToReview(nonceToken: nonceToken, storeId: storeId, reviewId: reviewId, input: input).asyncRequest()
    }
    
    func reportReview(storeId: String, reviewId: String, input: ReportCreateRequest) async -> ApiResult<String> {
        return await ReviewApi.reportReview(storeId: storeId, reviewId: reviewId, input: input).asyncRequest()
    }
    
    func deleteReviewComment(storeId: String, reviewId: String, commentId: String) async -> ApiResult<String> {
        return await ReviewApi.deleteReviewComment(storeId: storeId, reviewId: reviewId, commentId: commentId).asyncRequest()
    }
    
    func fetchCommentPresets(storeId: String) async -> ApiResult<ContentListWithCursorAndCount<CommentPresetResponse>> {
        return await ReviewApi.fetchCommentPreset(storeId: storeId).asyncRequest()
    }
    
    func addCommentPreset(nonceToken: String, storeId: String, input: CommentPresetCreateRequest) async -> ApiResult<CommentPresetResponse> {
        return await ReviewApi.addCommentPreset(nonceToken: nonceToken, storeId: storeId, input: input).asyncRequest()
    }
    
    func editCommentPreset(storeId: String, commentPresetId: String, input: CommentPresetPatchRequest) async -> ApiResult<String> {
        return await ReviewApi.editCommentPreset(storeId: storeId, presetId: commentPresetId, input: input).asyncRequest()
    }
    
    func deleteCommentPreset(storeId: String, commentPresetId: String) async -> ApiResult<String> {
        return await ReviewApi.deleteCommentPreset(storeId: storeId, presetId: commentPresetId).asyncRequest()
    }
}
