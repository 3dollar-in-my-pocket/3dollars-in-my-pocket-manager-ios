import Foundation
import Combine

extension StatisticsViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .statistics
        let sections = CurrentValueSubject<[StatisticsSection], Never>([])
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Relay {
        let didTapMessage = PassthroughSubject<Void, Never>()
        let didTapSeeMore = PassthroughSubject<Void, Never>()
    }
    
    struct State {
        var store: BossStoreResponse? = nil
        var feedbackTypes: [FeedbackTypeResponse] = []
        var feedbacks: [FeedbackCountWithRatioResponse] = []
    }
    
    enum Route {
        case pushFeedbackDetail(FeedbackDetailViewModel)
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let feedbackRepository: FeedbackRepository
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol
        let preference: Preference
        
        init(
            feedbackRepository: FeedbackRepository = FeedbackRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = .shared
        ) {
            self.feedbackRepository = feedbackRepository
            self.storeRepository = storeRepository
            self.logManager = logManager
            self.preference = preference
        }
    }
}

final class StatisticsViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let relay = Relay()
    private var state = State()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
        bindRelay()
    }
    
    private func bind() {
        Publishers.Merge(input.viewDidLoad, input.refresh)
            .withUnretained(self)
            .sink { (owner: StatisticsViewModel, _) in
                owner.fetchDatas()
            }
            .store(in: &cancellables)
    }
    
    private func bindRelay() {
        // TODO: message 탭 선택 로직 처리 필요
        
        relay.didTapSeeMore
            .withUnretained(self)
            .sink { (owner: StatisticsViewModel, _) in
                let viewModel = FeedbackDetailViewModel()
                owner.output.route.send(.pushFeedbackDetail(viewModel))
            }
            .store(in: &cancellables)
    }
    
    private func fetchDatas() {
        Task {
            do {
                let feedbackTypes = try await dependency.feedbackRepository.fetchFeedbackType().get()
                state.feedbackTypes = feedbackTypes
                
                let myStore = try await dependency.storeRepository.fetchMyStore().get()
                state.store = myStore
                
                let feedbacks = try await dependency.feedbackRepository.fetchTotalStatistics(storeId: dependency.preference.storeId).get()
                state.feedbacks = feedbacks
                output.sections.send(createSections())
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func createSections() -> [StatisticsSection] {
        var sections: [StatisticsSection] = []
        if let store = state.store {
            let config = StatisticsBookmarkCountCellViewModel.Config(bookmarkCount: store.favorite.subscriberCount)
            let viewModel = StatisticsBookmarkCountCellViewModel(config: config)
            
            viewModel.output.didTapSendMessage
                .subscribe(relay.didTapMessage)
                .store(in: &viewModel.cancellables)
            sections.append(.init(type: .bookmark, items: [.bookmarkCount(viewModel)]))
        }
        
        if state.feedbacks.isNotEmpty {
            let top3Feedbacks = state.feedbacks
                .filter { $0.count > 0 }
                .sorted(by: { $0.count > $1.count })
                .prefix(3)
            let config = StatisticsFeedbackCountCellViewModel.Config(
                feedbackTypes: state.feedbackTypes,
                statistics: Array(top3Feedbacks)
            )
            let viewModel = StatisticsFeedbackCountCellViewModel(config: config)
            
            viewModel.output.didTapSeeMore
                .subscribe(relay.didTapSeeMore)
                .store(in: &viewModel.cancellables)
            sections.append(.init(type: .feedback, items: [.feedback(viewModel)]))
        }
        
        return sections
    }
}
