import Combine

extension ReviewListItemCellViewModel {
    struct Output {
        let review: StoreReviewResponse
        let didTapPhoto = PassthroughSubject<(review: StoreReviewResponse, index: Int), Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct Config {
        let review: StoreReviewResponse
    }
}

final class ReviewListItemCellViewModel: BaseViewModel, Identifiable {
    let output: Output
    lazy var id = ObjectIdentifier(self)
    let reviewItemViewModel: ReviewItemViewModel
    
    init(config: Config) {
        self.output = Output(review: config.review)
        
        let config = ReviewItemViewModel.Config(review: config.review)
        self.reviewItemViewModel = ReviewItemViewModel(config: config)
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        reviewItemViewModel.output.didTapPhoto
            .subscribe(output.didTapPhoto)
            .store(in: &cancellables)
        
        reviewItemViewModel.output.showErrorAlert
            .subscribe(output.showErrorAlert)
            .store(in: &cancellables)
    }
}

extension ReviewListItemCellViewModel: Hashable {
    static func == (lhs: ReviewListItemCellViewModel, rhs: ReviewListItemCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
