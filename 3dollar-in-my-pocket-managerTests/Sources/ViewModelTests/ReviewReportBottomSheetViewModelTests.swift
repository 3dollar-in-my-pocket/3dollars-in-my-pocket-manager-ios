import Combine
import XCTest

@testable import _dollar_in_my_pocket_manager

final class ReviewReportBottomSheetViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1384 TC1

    func test_TH1384_TC1_신고사유가10자미만이면_신고버튼이비활성화된다() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.input.inputText.send("짧은사유")

        // Then
        XCTAssertFalse(viewModel.output.isEnableReportButton.value)
    }

    func test_TH1384_TC1_신고사유가10자이상이면_신고버튼이활성화된다() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.input.inputText.send("열글자이상인신고사유입니다")

        // Then
        XCTAssertTrue(viewModel.output.isEnableReportButton.value)
    }

    // MARK: TH-1384 TC2

    func test_TH1384_TC2_신고에성공하면_토스트와dismissRoute가발행된다() async {
        // Given
        let repository = MockReviewRepository()
        repository.reportReviewResult = .success("OK")
        let viewModel = makeViewModel(reviewId: "review-1", repository: repository)
        let toastExpectation = expectation(description: "toast")
        let routeExpectation = expectation(description: "dismiss")
        viewModel.output.toast
            .sink { _ in toastExpectation.fulfill() }
            .store(in: &cancellables)
        viewModel.output.route
            .sink { route in
                if case .dismiss = route { routeExpectation.fulfill() }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.inputText.send("열글자이상인신고사유입니다")
        viewModel.input.didTapReport.send(())

        // Then
        await fulfillment(of: [toastExpectation, routeExpectation], timeout: 1)
        XCTAssertEqual(repository.reportReviewCalls.count, 1)
        XCTAssertEqual(repository.reportReviewCalls.first?.reviewId, "review-1")
        XCTAssertEqual(repository.reportReviewCalls.first?.input.reasonDetail, "열글자이상인신고사유입니다")
    }

    // MARK: TH-1384 TC3

    func test_TH1384_TC3_신고에실패하면_에러알럿Route가발행된다() async {
        // Given
        let repository = MockReviewRepository()
        repository.reportReviewResult = .failure(ApiError.emptyData)
        let viewModel = makeViewModel(repository: repository)
        let routeExpectation = expectation(description: "showErrorAlert")
        viewModel.output.route
            .sink { route in
                if case .showErrorAlert = route { routeExpectation.fulfill() }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.inputText.send("열글자이상인신고사유입니다")
        viewModel.input.didTapReport.send(())

        // Then
        await fulfillment(of: [routeExpectation], timeout: 1)
    }

    private func makeViewModel(
        reviewId: String = "review-id",
        repository: MockReviewRepository = MockReviewRepository()
    ) -> ReviewReportBottomSheetViewModel {
        ReviewReportBottomSheetViewModel(
            config: .init(reviewId: reviewId),
            dependency: .init(reviewRepository: repository)
        )
    }
}
