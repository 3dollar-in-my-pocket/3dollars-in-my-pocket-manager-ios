import Combine

extension ReviewListViewModel {
    enum Constants {
        static let pageSize = 20
    }
    
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let cellWillDisplay = PassthroughSubject<Int, Never>()
        let didTapSortType = PassthroughSubject<ReviewSortType, Never>()
        let didTapReview = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let dataSource = CurrentValueSubject<[ReviewListSection], Never>([])
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var bossStore: BossStoreResponse?
        var sortType: ReviewSortType = .latest
        var cursor: CursorString?
        var reviews: [StoreReviewResponse] = []
    }
    
    enum Route {
        case showErrorAlert(Error)
        case presentPhotoDetail(PhotoDetailViewModel)
        case pushReviewDetail(ReviewDetailViewModel)
    }
    
    struct Dependency {
        let reviewRepository: ReviewRepository
        let storeRepository: StoreRepository
        let preference: Preference
        let globalEventService: GlobalEventServiceType
        
        init(
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            preference: Preference = .shared,
            globalEventService: GlobalEventServiceType = GlobalEventService.shared
        ) {
            self.reviewRepository = reviewRepository
            self.storeRepository = storeRepository
            self.preference = preference
            self.globalEventService = globalEventService
        }
    }
}

final class ReviewListViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    private var cancelTaskBag = AnyCancelTaskBag()
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
        bindGlobalEvent()
    }
    
    private func bind() {
        Publishers.Merge(input.firstLoad, input.refresh)
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, _) in
                owner.clearPage()
                owner.loadFirstDatas()
            }
            .store(in: &cancellables)
        
        input.cellWillDisplay
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, index: Int) in
                guard owner.canLoadMore(index: index) else { return }
                
                owner.loadMoreReviews()
            }
            .store(in: &cancellables)
        
        input.didTapSortType
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, sortType: ReviewSortType) in
                owner.state.sortType = sortType
                owner.clearPage()
                owner.loadMoreReviews()
            }
            .store(in: &cancellables)
        
        input.didTapReview
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, index: Int) in
                guard let review = owner.state.reviews[safe: index] else { return }
                
                owner.pushReviewDetail(review: review)
            }
            .store(in: &cancellables)
    }
    
    private func bindGlobalEvent() {
        dependency.globalEventService.didUpdateReview
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, review: StoreReviewResponse) in
                guard let targetIndex = owner.state.reviews.firstIndex(where: { $0.reviewId == review.reviewId }) else { return }
                owner.state.reviews[targetIndex] = review
                owner.output.dataSource.send(owner.createSections())
            }
            .store(in: &cancellables)
    }
    
    private func loadFirstDatas() {
        Task {
            let storeId = dependency.preference.storeId
            
            do {
                let storeResponse = try await dependency.storeRepository.fetchMyStore().get()
                let reviewResponse = try await dependency.reviewRepository.fetchReviews(
                    storeId: storeId,
                    sort: state.sortType,
                    cursor: state.cursor?.nextCursor,
                    size: Constants.pageSize
                ).get()
                
                state.bossStore = storeResponse
                state.cursor = reviewResponse.cursor
                state.reviews += reviewResponse.contents.filter { $0.status != .deleted }
                output.dataSource.send(createSections())
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func loadMoreReviews() {
        Task {
            let storeId = dependency.preference.storeId
            let result = await dependency.reviewRepository.fetchReviews(
                storeId: storeId,
                sort: state.sortType,
                cursor: state.cursor?.nextCursor,
                size: Constants.pageSize
            )
            
            switch result {
            case .success(let response):
                state.cursor = response.cursor
                state.reviews += response.contents.filter { $0.status != .deleted }
                output.dataSource.send(createSections())
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return (index >= state.reviews.count - 1) && (state.cursor?.hasMore == true)
    }
    
    private func clearPage() {
        state.reviews.removeAll()
        state.cursor = nil
    }
    
    private func createSections() -> [ReviewListSection] {
        guard let store = state.bossStore else { return [] }
        
        var sections: [ReviewListSection] = []
        sections.append(.init(type: .overview, items: [.overview(totalReviewCount: store.reviews.cursor.totalCount, rating: store.rating)]))
        
        let reviewItems: [ReviewListSectionItem] = state.reviews.map {
            let cellViewModel = bindReviewListItemCellViewModel(review: $0)
            return .review(cellViewModel)
        }
        
        sections.append(.init(type: .reviewList(state.sortType), items: reviewItems))
        return sections
    }
    
    private func bindReviewListItemCellViewModel(review: StoreReviewResponse) -> ReviewListItemCellViewModel {
        let config = ReviewListItemCellViewModel.Config(review: review)
        let viewModel = ReviewListItemCellViewModel(config: config)
        
        viewModel.output.didTapPhoto
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, data: (review: StoreReviewResponse, index: Int)) in
                owner.presentPhotoDetail(review: data.review, index: data.index)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.output.showErrorAlert
            .map { Route.showErrorAlert($0) }
            .subscribe(output.route)
            .store(in: &viewModel.cancellables)
        return viewModel
    }
    
    private func presentPhotoDetail(review: StoreReviewResponse, index: Int) {
        let config = PhotoDetailViewModel.Config(images: review.images, currentIndex: index)
        let viewModel = PhotoDetailViewModel(config: config)
        output.route.send(.presentPhotoDetail(viewModel))
    }
    
    private func pushReviewDetail(review: StoreReviewResponse) {
        let config = ReviewDetailViewModel.Config(reviewId: review.reviewId)
        let viewModel = ReviewDetailViewModel(config: config)
        
        output.route.send(.pushReviewDetail(viewModel))
    }
}
