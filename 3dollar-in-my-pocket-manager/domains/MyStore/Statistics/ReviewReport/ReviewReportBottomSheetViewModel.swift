import Combine

extension ReviewReportBottomSheetViewModel {
    enum Constants {
        static let minLength = 10
        static let maxLength = 300
    }
    
    struct Input {
        let inputText = PassthroughSubject<String?, Never>()
        let didTapReport = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let isEnableReportButton = CurrentValueSubject<Bool, Never>(false)
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        let reviewId: String
        var reportContents: String?
    }
    
    struct Config {
        let reviewId: String
    }
    
    enum Route {
        case dismiss
        case showErrorAlert(Error)
    }
    
    
    struct Dependency {
        let reviewRepository: ReviewRepository
        let preference: Preference
        
        init(
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.reviewRepository = reviewRepository
            self.preference = preference
        }
    }
}

final class ReviewReportBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state: State
    private let dependency: Dependency
    
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.state = State(reviewId: config.reviewId)
        self.dependency = dependency
        
        super.init()
        bind()
    }
    
    private func bind() {
        input.inputText
            .withUnretained(self)
            .sink { (owner: ReviewReportBottomSheetViewModel, text: String?) in
                owner.state.reportContents = text
                
                if let text {
                    let isEnableReportButton = text.count >= Constants.minLength
                    owner.output.isEnableReportButton.send(isEnableReportButton)
                }
            }
            .store(in: &cancellables)
        
        input.didTapReport
            .withUnretained(self)
            .sink { (owner: ReviewReportBottomSheetViewModel, _) in
                owner.reportReview()
            }
            .store(in: &cancellables)
    }
    
    private func reportReview() {
        guard let reportContents = state.reportContents else { return }
        
        let storeId = dependency.preference.storeId
        let input = ReportCreateRequest(reasonDetail: reportContents)
        
        Task {
            let result = await dependency.reviewRepository.reportReview(
                storeId: storeId,
                reviewId: state.reviewId,
                input: input
            )
            
            switch result {
            case .success:
                output.toast.send(Strings.ReviewReportBottomSheet.Toast.report)
                output.route.send(.dismiss)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}
