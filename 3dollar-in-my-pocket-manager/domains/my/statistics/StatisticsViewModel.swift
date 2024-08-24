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
        let setPageViewController = PassthroughSubject<(TotalStatisticsViewModel), Never>()
        let filter = PassthroughSubject<StatisticsFilterButton.FilterType, Never>()
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
            
            output.setPageViewController.send(totalStatisticsViewModel)
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

//final class StatisticsReactor: Reactor {
//    enum Action {
//        case refresh
//        case tapFilterButton(StatisticsFilterButton.FilterType)
//    }
//    
//    enum Mutation {
//        case updateReviewCount(Int)
//        case setTab(StatisticsFilterButton.FilterType)
//        case refresh(StatisticsFilterButton.FilterType)
//    }
//    
//    struct State {
//        var totalReviewCount: Int
//        var selectedFilter: StatisticsFilterButton.FilterType
//    }
//    
//    let initialState: State
//    let refreshPublisher = PublishRelay<StatisticsFilterButton.FilterType>()
//    private let globalState: GlobalState
//    private let logManager: LogManagerProtocol
//    
//    init(
//        globalState: GlobalState,
//        logManager: LogManagerProtocol,
//        state: State = State(
//            totalReviewCount: 0,
//            selectedFilter: .total
//        )
//    ) {
//        self.globalState = globalState
//        self.logManager = logManager
//        self.initialState = state
//    }
//    
//    func mutate(action: Action) -> Observable<Mutation> {
//        switch action {
//        case .tapFilterButton(let filterType):
//            logManager.sendEvent(.init(
//                screen: .statistics,
//                eventName: .tapStatisticTab,
//                extraParameters: [.filterType: filterType.name]
//            ))
//            return .just(.setTab(filterType))
//            
//        case .refresh:
//            return .just(.refresh(self.currentState.selectedFilter))
//        }
//    }
//    
//    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
//        return .merge([
//            mutation,
//            self.globalState.updateReviewCountPublisher
//                .map { .updateReviewCount($0) }
//        ])
//    }
//    
//    func reduce(state: State, mutation: Mutation) -> State {
//        var newState = state
//        
//        switch mutation {
//        case .updateReviewCount(let totalReviewCount):
//            newState.totalReviewCount = totalReviewCount
//            
//        case .setTab(let filterType):
//            newState.selectedFilter = filterType
//            
//        case .refresh(let filterType):
//            self.refreshPublisher.accept(filterType)
//        }
//        
//        return newState
//    }
//}
