import Combine

extension StatisticsFeedbackCountCellViewModel {
    struct Input {
        let didTapSeeMore = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let didTapSeeMore = PassthroughSubject<Void, Never>()
        let reviewCount: Int
        let feedbackTypes: [FeedbackTypeResponse]
        let statistics: [FeedbackCountWithRatioResponse]
    }
    
    struct Config {
        let feedbackTypes: [FeedbackTypeResponse]
        let statistics: [FeedbackCountWithRatioResponse]
    }
}

final class StatisticsFeedbackCountCellViewModel: BaseViewModel, Identifiable {
    lazy var id = ObjectIdentifier(self)
    let input = Input()
    let output: Output
    
    init(config: Config) {
        let reviewCount = config.statistics.map { $0.count }.reduce(0, +)
        self.output = Output(
            reviewCount: reviewCount,
            feedbackTypes: config.feedbackTypes,
            statistics: config.statistics
        )
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapSeeMore
            .subscribe(output.didTapSeeMore)
            .store(in: &cancellables)
    }
}

extension StatisticsFeedbackCountCellViewModel: Hashable {
    static func == (lhs: StatisticsFeedbackCountCellViewModel, rhs: StatisticsFeedbackCountCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
