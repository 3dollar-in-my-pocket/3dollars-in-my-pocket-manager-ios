import Foundation
import Combine

extension StatisticsViewModel {
    enum Constants {
        static let feedbackSize = 3
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let didTapReview = PassthroughSubject<Int, Never>()
        let didTapMoreReview = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .statistics
        let sections = CurrentValueSubject<[StatisticsSection], Never>([])
        let didTapMessage = PassthroughSubject<Void, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Relay {
        let didTapMessage = PassthroughSubject<Void, Never>()
        let didTapSeeMore = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<(review: StoreReviewResponse, index: Int), Never>()
    }
    
    struct State {
        var store: BossStoreResponse? = nil
        var feedbackTypes: [FeedbackTypeResponse] = []
        var feedbacks: [FeedbackCountWithRatioResponse] = []
        var reviews: ContentListWithCursorAndCount<StoreReviewResponse>?
    }
    
    enum Route {
        case pushFeedbackDetail(FeedbackDetailViewModel)
        case presentPhotoDetail(PhotoDetailViewModel)
        case pushReviewList(ReviewListViewModel)
        case pushReviewDetail(ReviewDetailViewModel)
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
        
        input.didTapMoreReview
            .withUnretained(self)
            .sink { (owner: StatisticsViewModel, _) in
                owner.pushReviewList()
            }
            .store(in: &cancellables)
        
        input.didTapReview
            .withUnretained(self)
            .sink { (owner: StatisticsViewModel, index: Int) in
                owner.pushReviewDetail(index: index)
            }
            .store(in: &cancellables)
    }
    
    private func bindRelay() {
        relay.didTapMessage
            .subscribe(output.didTapMessage)
            .store(in: &cancellables)
        
        relay.didTapSeeMore
            .withUnretained(self)
            .sink { (owner: StatisticsViewModel, _) in
                let viewModel = FeedbackDetailViewModel()
                owner.output.route.send(.pushFeedbackDetail(viewModel))
            }
            .store(in: &cancellables)
        
        relay.didTapPhoto
            .withUnretained(self)
            .sink { (owner: StatisticsViewModel, data) in
                let (review, index) = data
                owner.presentPhotoDetail(review: review, index: index)
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
                let cellViewModels = reviews.contents.map { createReviewItemViewModel(review: $0) }
                let items: [StatisticsSectionItem] = cellViewModels.map { .review($0) }
                sections.append(.init(type: headerType, items: items))
            }
        }
        
        return sections
    }
    
    private func createReviewItemViewModel(review: StoreReviewResponse) ->  ReviewItemViewModel {
        let config = ReviewItemViewModel.Config(review: review)
        let viewModel = ReviewItemViewModel(config: config)
        
        viewModel.output.didTapPhoto
            .subscribe(relay.didTapPhoto)
            .store(in: &viewModel.cancellables)
        return viewModel
    }
    
    private func presentPhotoDetail(review: StoreReviewResponse, index: Int) {
        let config = PhotoDetailViewModel.Config(images: review.images, currentIndex: index)
        let viewModel = PhotoDetailViewModel(config: config)
        output.route.send(.presentPhotoDetail(viewModel))
    }
    
    private func pushReviewList() {
        let viewModel = ReviewListViewModel()
        output.route.send(.pushReviewList(viewModel))
    }
    
    private func pushReviewDetail(index: Int) {
        guard let review = state.reviews?.contents[safe: index] else { return }
        let config = ReviewDetailViewModel.Config(reviewId: review.reviewId)
        let viewModel = ReviewDetailViewModel(config: config)
        
        output.route.send(.pushReviewDetail(viewModel))
    }
}
