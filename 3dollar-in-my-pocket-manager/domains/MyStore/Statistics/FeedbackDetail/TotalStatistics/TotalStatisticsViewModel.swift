import Foundation
import Combine

extension TotalStatisticsViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let viewWillAppear = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let feedbackTypes: [FeedbackTypeResponse]
        let statistics = PassthroughSubject<[FeedbackCountWithRatioResponse], Never>()
        let reviewTotalCount = PassthroughSubject<Int, Never>()
        let updateContainerHeight = PassthroughSubject<CGFloat, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var containerHeight: CGFloat = .zero
    }
    
    enum Route {
        case showErrorAlert(Error)
    }
    
    struct Config {
        let feedbackTypes: [FeedbackTypeResponse]
    }
    
    struct Dependency {
        let feedbackRepository: FeedbackRepository
        let userDefaults: Preference
        
        init(
            feedbackRepository: FeedbackRepository = FeedbackRepositoryImpl(),
            userDefaults: Preference = .shared
        ) {
            self.feedbackRepository = feedbackRepository
            self.userDefaults = userDefaults
        }
    }
}

final class TotalStatisticsViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state = State()
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(feedbackTypes: config.feedbackTypes)
        self.dependency = dependency
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: TotalStatisticsViewModel, _) in
                owner.fetchStatistics()
            }
            .store(in: &cancellables)
        
        input.viewWillAppear
            .withUnretained(self)
            .sink { (owner: TotalStatisticsViewModel, _) in
                owner.output.updateContainerHeight.send(owner.state.containerHeight)
            }
            .store(in: &cancellables)
    }
    
    private func fetchStatistics() {
        let storeId = dependency.userDefaults.storeId
        
        Task {
            let result = await dependency.feedbackRepository.fetchTotalStatistics(storeId: storeId)
            
            switch result {
            case .success(let statistics):
                let reviewTotalCount = statistics.map { $0.count }.reduce(0, +)
                
                output.reviewTotalCount.send(reviewTotalCount)
                output.statistics.send(statistics)
                updateContainerHeight(statistics)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func updateContainerHeight(_ statistics: [FeedbackCountWithRatioResponse]) {
        let itemHeight = TotalStatisticsItemView.Layout.height * CGFloat(statistics.count)
        let space = TotalStatisticsViewController.Layout.spacing * CGFloat(statistics.count - 1)
        let totalHeight = TotalStatisticsViewController.Layout.topPadding + itemHeight + space
        
        state.containerHeight = totalHeight
        output.updateContainerHeight.send(totalHeight)
    }
}
