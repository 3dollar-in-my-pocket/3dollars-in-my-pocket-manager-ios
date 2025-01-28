import Combine

extension StatisticsReviewCellViewModel {
    struct Input {
        let didTapPhoto = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let review: StoreReviewResponse
        let didTapPhoto = PassthroughSubject<Int, Never>()
    }
    
    struct Config {
        let review: StoreReviewResponse
    }
}

final class StatisticsReviewCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(review: config.review)
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapPhoto
            .subscribe(output.didTapPhoto)
            .store(in: &cancellables)
    }
}

extension StatisticsReviewCellViewModel: Hashable {
    static func == (lhs: StatisticsReviewCellViewModel, rhs: StatisticsReviewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(output.review)
    }
}
