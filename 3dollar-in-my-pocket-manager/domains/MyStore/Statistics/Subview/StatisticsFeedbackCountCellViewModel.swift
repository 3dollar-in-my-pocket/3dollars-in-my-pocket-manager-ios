import Combine

extension StatisticsFeedbackCountCellViewModel {
    struct Input {
        let didTapSeeMore = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let didTapSeeMore = PassthroughSubject<Void, Never>()
        let feedbackCount: Int
        let feedbackTypes: [FeedbackTypeResponse]
        let top3Feedbacks: [FeedbackCountWithRatioResponse]
    }
    
    struct Config {
        let totalFeedbackCount: Int
        let feedbackTypes: [FeedbackTypeResponse]
        let top3Feedbacks: [FeedbackCountWithRatioResponse]
    }
}

final class StatisticsFeedbackCountCellViewModel: BaseViewModel, Identifiable {
    lazy var id = ObjectIdentifier(self)
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(
            feedbackCount: config.totalFeedbackCount,
            feedbackTypes: config.feedbackTypes,
            top3Feedbacks: config.top3Feedbacks
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
