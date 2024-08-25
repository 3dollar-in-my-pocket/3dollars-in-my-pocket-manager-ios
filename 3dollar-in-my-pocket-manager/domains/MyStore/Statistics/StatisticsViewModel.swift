import Foundation
import Combine

extension StatisticsViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let totalReviewCount = PassthroughSubject<Int, Never>()
        let didTapFilter = PassthroughSubject<StatisticsFilterButton.FilterType, Never>()
        let updateContainerHeight = PassthroughSubject<CGFloat, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .statistics
        let subscriberCount = PassthroughSubject<Int, Never>()
        let totalReviewCount = PassthroughSubject<Int, Never>()
        let setPageViewController = PassthroughSubject<(TotalStatisticsViewModel, DailyStatisticsViewModel), Never>()
        let filter = CurrentValueSubject<StatisticsFilterButton.FilterType, Never>(.total)
        let updateContainerHeight = PassthroughSubject<CGFloat, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var feedbackTypes: [FeedbackTypeResponse] = []
        var store: BossStoreResponse? = nil
        var selectedFilter: StatisticsFilterButton.FilterType = .total
    }
    
    enum Route {
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let feedbackRepository: FeedbackRepository
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol
        
        init(
            feedbackRepository: FeedbackRepository = FeedbackRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.feedbackRepository = feedbackRepository
            self.storeRepository = storeRepository
            self.logManager = logManager
        }
    }
}

final class StatisticsViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    
    var totalStatisticsViewModel: TotalStatisticsViewModel?
    var dailyStatisticsViewModel: DailyStatisticsViewModel?
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        Publishers.Merge(input.viewDidLoad, input.refresh)
            .withUnretained(self)
            .sink { (owner: StatisticsViewModel, _) in
                owner.fetchDatas()
            }
            .store(in: &cancellables)
        
        input.totalReviewCount
            .subscribe(output.totalReviewCount)
            .store(in: &cancellables)
        
        input.didTapFilter
            .withUnretained(self)
            .sink { (owner: StatisticsViewModel, filterType: StatisticsFilterButton.FilterType) in
                owner.state.selectedFilter = filterType
                owner.sendClickFilterLog(filterType: filterType)
                owner.output.filter.send(filterType)
            }
            .store(in: &cancellables)
        
        input.updateContainerHeight
            .subscribe(output.updateContainerHeight)
            .store(in: &cancellables)
    }
    
    private func fetchDatas() {
        Task {
            let fetchFeedbackTypes = await dependency.feedbackRepository.fetchFeedbackType()
            switch fetchFeedbackTypes {
            case .success(let feedbackTypes):
                state.feedbackTypes = feedbackTypes
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
                return
            }
            
            let fetchMyStore = await dependency.storeRepository.fetchMyStore()
            switch fetchMyStore {
            case .success(let store):
                state.store = store
                output.subscriberCount.send(store.favorite.subscriberCount)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
                return
            }
            
            let totalStatisticsViewModel = createTotalStatisticsViewModel()
            self.totalStatisticsViewModel = totalStatisticsViewModel
            
            let dailyStatisticsViewModel = createDailyStatisticsViewModel()
            self.dailyStatisticsViewModel = dailyStatisticsViewModel
            
            output.setPageViewController.send((totalStatisticsViewModel, dailyStatisticsViewModel))
        }
    }
    
    private func createTotalStatisticsViewModel() -> TotalStatisticsViewModel {
        let config = TotalStatisticsViewModel.Config(feedbackTypes: state.feedbackTypes)
        let viewModel = TotalStatisticsViewModel(config: config)
        
        viewModel.output.reviewTotalCount
            .subscribe(input.totalReviewCount)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.updateContainerHeight
            .subscribe(input.updateContainerHeight)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }
    
    private func createDailyStatisticsViewModel() -> DailyStatisticsViewModel {
        let config = DailyStatisticsViewModel.Config(feedbackTypes: state.feedbackTypes)
        let viewModel = DailyStatisticsViewModel(config: config)
        
        viewModel.output.updateContainerHeight
            .subscribe(input.updateContainerHeight)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }
}

// MARK: Log
extension StatisticsViewModel {
    func sendClickFilterLog(filterType: StatisticsFilterButton.FilterType) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .tapStatisticTab,
            extraParameters: [.filterType: filterType])
        )
    }
}
