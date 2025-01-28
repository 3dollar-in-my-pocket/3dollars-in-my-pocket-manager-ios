import Foundation
import Combine

extension StatisticsViewModel {
    enum Constants {
        static let feedbackSize = 3
    }
    
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
        var reviews: ContentListWithCursorAndCount<StoreReviewResponse>?
    }
    
    enum Route {
        case pushFeedbackDetail(FeedbackDetailViewModel)
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let feedbackRepository: FeedbackRepository
        let storeRepository: StoreRepository
        let reviewRepository: ReviewRepository
        let logManager: LogManagerProtocol
        let preference: Preference
        
        init(
            feedbackRepository: FeedbackRepository = FeedbackRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = .shared
        ) {
            self.feedbackRepository = feedbackRepository
            self.storeRepository = storeRepository
            self.reviewRepository = reviewRepository
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
                let storeId = dependency.preference.storeId
                let feedbackTypes = try await dependency.feedbackRepository.fetchFeedbackType().get()
                state.feedbackTypes = feedbackTypes
                
                let myStore = try await dependency.storeRepository.fetchMyStore().get()
                state.store = myStore
                state.reviews = myStore.reviews
                
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
        
        if let reviews = state.reviews {
            let totalReviewCount = reviews.cursor.totalCount
            let headerType = StatisticsSectionType.review(
                totalReviewCount: totalReviewCount,
                rating: state.store?.rating ?? 0
            )
            
            if reviews.contents.isEmpty {
                sections.append(.init(type: headerType, items: [.emptyReview]))
            } else {
                let cellViewModels = reviews.contents.map {
                    let config = StatisticsReviewCellViewModel.Config(review: $0)
                    let viewModel = StatisticsReviewCellViewModel(config: config)
                    return viewModel
                }
                
                let items: [StatisticsSectionItem] = cellViewModels.map { .review($0) }
                sections.append(.init(type: headerType, items: items))
            }
        }
        
        return sections
    }
}
