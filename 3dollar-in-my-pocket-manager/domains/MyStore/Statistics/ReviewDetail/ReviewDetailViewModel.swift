import Combine

extension ReviewDetailViewModel {
    enum Constant {
        static let minReplyLength = 10
    }
    
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapReport = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let didTapLike = PassthroughSubject<Void, Never>()
        let inputReply = PassthroughSubject<String, Never>()
        let didTapMacro = PassthroughSubject<Void, Never>()
        let didTapComment = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let review = PassthroughSubject<ReviewItemViewModel, Never>()
        let comment = PassthroughSubject<String?, Never>()
        let enableComment = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Relay {
        let didTapPhoto = PassthroughSubject<(review: StoreReviewResponse, index: Int), Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct State {
        let reviewId: String
        var review: StoreReviewResponse?
        var reviewItemViewModel: ReviewItemViewModel?
        var comment: String?
        var commentId: String?
    }
    
    enum Route {
        case back
        case presentPhotoDetail(PhotoDetailViewModel)
        case presentReport
        case showErrorAlert(Error)
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
    
    struct Config {
        let reviewId: String
    }
}

final class ReviewDetailViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state: State
    private let relay = Relay()
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.state = State(reviewId: config.reviewId)
        self.dependency = dependency
        
        super.init()
        
        bind()
        bindRelay()
    }
    
    private func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, _) in
                owner.fetchReview()
            }
            .store(in: &cancellables)
        
        input.inputReply
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, reply: String) in
                owner.state.comment = reply
                owner.validateComment()
            }
            .store(in: &cancellables)
        
        input.didTapComment
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, _) in
                owner.createCommentToReply()
            }
            .store(in: &cancellables)
        
        input.didTapReport
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, _) in
                owner.presentReportBottomSheet()
            }
            .store(in: &cancellables)
    }
    
    private func bindRelay() {
        relay.didTapPhoto
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, data) in
                let (review, index) = data
                owner.presentPhotoDetail(review: review, index: index)
            }
            .store(in: &cancellables)
        
        relay.showErrorAlert
            .map { Route.showErrorAlert($0) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func fetchReview() {
        Task {
            let storeId = dependency.preference.storeId
            let result = await dependency.reviewRepository.fetchReview(storeId: storeId, reviewId: state.reviewId)
            
            switch result {
            case .success(let response):
                state.review = response
                
                let config = ReviewItemViewModel.Config(review: response)
                let viewModel = ReviewItemViewModel(config: config)
                bindReviewItemViewModel(viewModel)
                output.review.send(viewModel)
                output.comment.send(response.comments.contents.first?.content)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func bindReviewItemViewModel(_ viewModel: ReviewItemViewModel) {
        viewModel.output.didTapPhoto
            .subscribe(relay.didTapPhoto)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.showErrorAlert
            .subscribe(relay.showErrorAlert)
            .store(in: &viewModel.cancellables)
    }
    
    private func presentPhotoDetail(review: StoreReviewResponse, index: Int) {
        let config = PhotoDetailViewModel.Config(images: review.images, currentIndex: index)
        let viewModel = PhotoDetailViewModel(config: config)
        
        output.route.send(.presentPhotoDetail(viewModel))
    }
    
    private func validateComment() {
        let isValid = (state.comment ?? "").count >= Constant.minReplyLength
        output.enableComment.send(isValid)
    }
    
    private func createCommentToReply() {
        guard let comment = state.comment else { return }
        
        Task {
            let input = CommentCreateRequest(content: comment)
            let storeId = dependency.preference.storeId
            
            let result = await dependency.reviewRepository.createCommentToReview(storeId: storeId, reviewId: state.reviewId, input: input)
            
            switch result {
            case .success(let response):
                state.commentId = response.commentId
                output.comment.send(comment)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func presentReportBottomSheet() {
        output.route.send(.presentReport)
    }
}
