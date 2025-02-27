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
        let didTapCommentPreset = PassthroughSubject<Void, Never>()
        let didTapComment = PassthroughSubject<Void, Never>()
        let didTapDeleteComment = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let review = PassthroughSubject<ReviewItemViewModel, Never>()
        let comment = PassthroughSubject<(CommentResponse?, String), Never>()
        let setCommentPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let enableComment = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Relay {
        let didTapPhoto = PassthroughSubject<(review: StoreReviewResponse, index: Int), Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
        let finishAddCommentPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let finishEditCommentPreset = PassthroughSubject<Void, Never>()
        let didTapEditPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapPreset = PassthroughSubject<CommentPresetResponse, Never>()
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
        case presentReportBottomSheet(ReviewReportBottomSheetViewModel)
        case presentCommentPreset(CommentPresetBottomSheetViewModel)
        case presentAddCommentPreset(AddCommentPresetBottomSheetViewModel)
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let reviewRepository: ReviewRepository
        let sharedRepository: SharedRepository
        let preference: Preference
        
        init(
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            sharedRepository: SharedRepository = SharedRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.reviewRepository = reviewRepository
            self.sharedRepository = sharedRepository
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
        
        input.didTapDeleteComment
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, _) in
                owner.deleteReviewComment()
            }
            .store(in: &cancellables)
        
        input.didTapCommentPreset
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, _) in
                owner.presentCommentPresetBottomSheet()
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
        
        relay.didTapAddPreset
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, _) in
                owner.presentAddCommentPresetBottomSheet()
            }
            .store(in: &cancellables)
        
        relay.finishAddCommentPreset
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, response: CommentPresetResponse) in
                owner.presentCommentPresetBottomSheet()
            }
            .store(in: &cancellables)
        
        relay.didTapEditPreset
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, commentPreset: CommentPresetResponse) in
                owner.presentAddCommentPresetBottomSheet(commentPreset: commentPreset)
            }
            .store(in: &cancellables)
        relay.finishEditCommentPreset
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, _) in
                owner.presentCommentPresetBottomSheet()
            }
            .store(in: &cancellables)
        
        relay.didTapPreset
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewModel, commentPreset: CommentPresetResponse) in
                owner.state.comment = commentPreset.body
                owner.validateComment()
                owner.output.setCommentPreset.send(commentPreset)
            }
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
                
                let comment = response.comments.contents.first(where: { comment in
                    return comment.isOwner && comment.status == .active
                })
                let name = dependency.preference.storeName
                output.comment.send((comment, name))
                state.commentId = comment?.commentId
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
            do {
                let token = try await dependency.sharedRepository.createNonce(input: NonceCreateRequest()).get().nonce
                let input = CommentCreateRequest(content: comment)
                let storeId = dependency.preference.storeId
                
                let comment = try await dependency.reviewRepository.createCommentToReview(
                    nonceToken: token,
                    storeId: storeId,
                    reviewId: state.reviewId,
                    input: input
                ).get()
                
                state.commentId = comment.commentId
                output.comment.send((comment, dependency.preference.storeName))
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func deleteReviewComment() {
        guard let commentId = state.commentId else { return }
        
        let storeId = dependency.preference.storeId
        Task {
            let result = await dependency.reviewRepository.deleteReviewComment(
                storeId: storeId,
                reviewId: state.reviewId,
                commentId: commentId
            )
            
            switch result {
            case .success:
                output.comment.send((nil, dependency.preference.storeName))
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func presentReportBottomSheet() {
        let config = ReviewReportBottomSheetViewModel.Config(reviewId: state.reviewId)
        let viewModel = ReviewReportBottomSheetViewModel(config: config)
        
        output.route.send(.presentReportBottomSheet(viewModel))
    }
    
    private func presentCommentPresetBottomSheet() {
        Task {
            let storeId = dependency.preference.storeId
            let result = await dependency.reviewRepository.fetchCommentPresets(storeId: storeId)
            
            switch result {
            case .success(let response):
                let config = CommentPresetBottomSheetViewModel.Config(presets: response.contents)
                let viewModel = CommentPresetBottomSheetViewModel(config: config)
                
                viewModel.output.didTapAddPreset
                    .subscribe(relay.didTapAddPreset)
                    .store(in: &viewModel.cancellables)
                
                viewModel.output.didTapPreset
                    .subscribe(relay.didTapPreset)
                    .store(in: &viewModel.cancellables)
                
                viewModel.relay.didTapEditPreset
                    .subscribe(relay.didTapEditPreset)
                    .store(in: &viewModel.cancellables)

                output.route.send(.presentCommentPreset(viewModel))
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func presentAddCommentPresetBottomSheet(commentPreset: CommentPresetResponse? = nil) {
        let config = AddCommentPresetBottomSheetViewModel.Config(commentPreset: commentPreset)
        let viewModel = AddCommentPresetBottomSheetViewModel(config: config)
        viewModel.output.finishAddCommentPreset
            .subscribe(relay.finishAddCommentPreset)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.finishEditCommentPreset
            .subscribe(relay.finishEditCommentPreset)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentAddCommentPreset(viewModel))
    }
}
