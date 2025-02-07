import Combine

extension ReviewListItemCellViewModel {
    struct Input {
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let didTapHeart = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let review: StoreReviewResponse
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
        
        init(
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.reviewRepository = reviewRepository
            self.preference = preference
        }
    }
}

final class ReviewListItemCellViewModel: BaseViewModel, Identifiable {
    let input = Input()
    let output: Output
    lazy var id = ObjectIdentifier(self)
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
    }
    
    private func bind() {
        input.didTapPhoto
            .withUnretained(self)
            .map { (owner: ReviewListItemCellViewModel, index) in
                (owner.output.review, index)
            }
            .subscribe(output.didTapPhoto)
            .store(in: &cancellables)
        
        input.didTapHeart
            .withUnretained(self)
            .sink { (owner: ReviewListItemCellViewModel, _) in
                owner.toggleLike()
            }
            .store(in: &cancellables)
    }
    
    private func toggleLike() {
        guard let stickerId = output.review.stickers.first?.stickerId else { return }
        Task {
            let storeId = dependency.preference.storeId
            let reviewId = output.review.reviewId
            let result = await dependency.reviewRepository.toggleLikeReview(
                storeId: storeId,
                reviewId: reviewId,
                input: .init(stickers: [.init(stickerId: stickerId)])
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
                output.likedByMe.send(likedByMe)
                output.likedCount.send(likedCount)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}

extension ReviewListItemCellViewModel: Hashable {
    static func == (lhs: ReviewListItemCellViewModel, rhs: ReviewListItemCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
