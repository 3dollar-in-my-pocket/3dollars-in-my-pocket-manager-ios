import Foundation

@testable import _dollar_in_my_pocket_manager

/// ReviewRepository 목. 메서드마다 `{메서드}Result` 를 스텁하고, 필요한 호출은 `{메서드}Calls` 로 기록한다.
final class MockReviewRepository: ReviewRepository {
    var fetchReviewsResult: ApiResult<ContentListWithCursor<StoreReviewResponse>> = .failure(MockError.notStubbed())
    var toggleLikeReviewResult: ApiResult<String> = .failure(MockError.notStubbed())
    var fetchReviewResult: ApiResult<StoreReviewResponse> = .failure(MockError.notStubbed())
    var createCommentToReviewResult: ApiResult<CommentResponse> = .failure(MockError.notStubbed())
    var reportReviewResult: ApiResult<String> = .failure(MockError.notStubbed())
    var deleteReviewCommentResult: ApiResult<String> = .failure(MockError.notStubbed())
    var fetchCommentPresetsResult: ApiResult<ContentListWithCursorAndCount<CommentPresetResponse>> = .failure(MockError.notStubbed())
    var addCommentPresetResult: ApiResult<CommentPresetResponse> = .failure(MockError.notStubbed())
    var editCommentPresetResult: ApiResult<String> = .failure(MockError.notStubbed())
    var deleteCommentPresetResult: ApiResult<String> = .failure(MockError.notStubbed())

    struct ReportReviewCall {
        let storeId: String
        let reviewId: String
        let input: ReportCreateRequest
    }

    private(set) var reportReviewCalls: [ReportReviewCall] = []

    func fetchReviews(storeId: String, sort: ReviewSortType?, cursor: String?, size: Int?) async -> ApiResult<ContentListWithCursor<StoreReviewResponse>> {
        fetchReviewsResult
    }

    func toggleLikeReview(storeId: String, reviewId: String, input: StickersReplaceRequest) async -> ApiResult<String> {
        toggleLikeReviewResult
    }

    func fetchReview(storeId: String, reviewId: String) async -> ApiResult<StoreReviewResponse> {
        fetchReviewResult
    }

    func createCommentToReview(nonceToken: String, storeId: String, reviewId: String, input: CommentCreateRequest) async -> ApiResult<CommentResponse> {
        createCommentToReviewResult
    }

    func reportReview(storeId: String, reviewId: String, input: ReportCreateRequest) async -> ApiResult<String> {
        reportReviewCalls.append(ReportReviewCall(storeId: storeId, reviewId: reviewId, input: input))
        return reportReviewResult
    }

    func deleteReviewComment(storeId: String, reviewId: String, commentId: String) async -> ApiResult<String> {
        deleteReviewCommentResult
    }

    func fetchCommentPresets(storeId: String) async -> ApiResult<ContentListWithCursorAndCount<CommentPresetResponse>> {
        fetchCommentPresetsResult
    }

    func addCommentPreset(nonceToken: String, storeId: String, input: CommentPresetCreateRequest) async -> ApiResult<CommentPresetResponse> {
        addCommentPresetResult
    }

    func editCommentPreset(storeId: String, commentPresetId: String, input: CommentPresetPatchRequest) async -> ApiResult<String> {
        editCommentPresetResult
    }

    func deleteCommentPreset(storeId: String, commentPresetId: String) async -> ApiResult<String> {
        deleteCommentPresetResult
    }
}
