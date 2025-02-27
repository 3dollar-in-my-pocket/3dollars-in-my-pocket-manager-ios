import Combine

extension ReviewItemViewModel {
    struct Input {
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let didTapHeart = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var review: StoreReviewResponse
        let likedByMe: CurrentValueSubject<Bool, Never>
        let likedCount: CurrentValueSubject<Int, Never>
        let didTapPhoto = PassthroughSubject<(review: StoreReviewResponse, index: Int), Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct Config {
        let review: StoreReviewResponse
    }
    
    struct Dependency {
        let reviewRepository: ReviewRepository
        let preference: Preference
        let globalEventService: GlobalEventServiceType
        
        init(
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            preference: Preference = .shared,
            globalEventService: GlobalEventServiceType = GlobalEventService.shared
        ) {
            self.reviewRepository = reviewRepository
            self.preference = preference
            self.globalEventService = globalEventService
        }
    }
}

final class ReviewItemViewModel: BaseViewModel, Identifiable {
    lazy var id = ObjectIdentifier(self)
    let input = Input()
    var output: Output
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        let likedByMe = config.review.stickers.first?.reactedByMe ?? false
        let likedCount = config.review.stickers.first?.count ?? 0
        
        self.output = Output(
            review: config.review,
            likedByMe: .init(likedByMe),
            likedCount: .init(likedCount)
        )
        self.dependency = dependency
        
        super.init()
        
        bind()
        bindGlobalEvent()
    }
    
    private func bind() {
        input.didTapPhoto
            .withUnretained(self)
            .map { (owner: ReviewItemViewModel, index) in
                (owner.output.review, index)
            }
            .subscribe(output.didTapPhoto)
            .store(in: &cancellables)
        
        input.didTapHeart
            .withUnretained(self)
            .sink { (owner: ReviewItemViewModel, _) in
                owner.toggleLike()
            }
            .store(in: &cancellables)
    }
    
    private func bindGlobalEvent() {
        dependency.globalEventService.didUpdateReview
            .withUnretained(self)
            .sink { (owner: ReviewItemViewModel, review: StoreReviewResponse) in
                guard review.reviewId == owner.output.review.reviewId else { return }
                owner.output.review = review
                owner.output.likedByMe.send(review.stickers.first?.reactedByMe ?? false)
                owner.output.likedCount.send(review.stickers.first?.count ?? 0)
            }
            .store(in: &cancellables)
    }
    
    private func toggleLike() {
        guard let stickerId = output.review.stickers.first?.stickerId else { return }
        Task {
            let storeId = dependency.preference.storeId
            let reviewId = output.review.reviewId
            let input: StickersReplaceRequest = output.likedByMe.value ? .init(stickers: []) : .init(stickers: [.init(stickerId: stickerId)])
            let result = await dependency.reviewRepository.toggleLikeReview(
                storeId: storeId,
                reviewId: reviewId,
                input: input
            )
            
            switch result {
            case .success(_):
                let likedByMe = !output.likedByMe.value
                var likedCount = output.likedCount.value
                
                if likedByMe {
                    likedCount += 1
                } else {
                    likedCount -= 1
                }
                
                if output.review.stickers.first.isNotNil {
                    output.review.stickers[0].count = likedCount
                    output.review.stickers[0].reactedByMe = likedByMe
                    dependency.globalEventService.didUpdateReview.send(output.review)
                }
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}

extension ReviewItemViewModel: Hashable {
    static func == (lhs: ReviewItemViewModel, rhs: ReviewItemViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
