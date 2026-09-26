import XCTest

@testable import _dollar_in_my_pocket_manager

final class ReviewApiTests: XCTestCase {

    // MARK: TH-1384 TC4

    func test_TH1384_TC4_리뷰신고API는_리뷰report경로와POST를쓴다() {
        // Given
        let api = ReviewApi.reportReview(
            storeId: "store-1",
            reviewId: "review-1",
            input: ReportCreateRequest(reasonDetail: "사유")
        )

        // When
        let path = api.path
        let method = api.method

        // Then
        XCTAssertEqual(path, "/v1/store/store-1/review/review-1/report")
        XCTAssertEqual(method, .post)
        XCTAssertEqual(api.parameters?["reasonDetail"] as? String, "사유")
    }
}
