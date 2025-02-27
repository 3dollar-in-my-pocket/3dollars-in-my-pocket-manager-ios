import Combine

extension AddCommentPresetBottomSheetViewModel {
    struct Input {
        let inputText = PassthroughSubject<String?, Never>()
        let didTapAdd = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let commentPreset: CommentPresetResponse?
        let isEnableAddButton: CurrentValueSubject<Bool, Never>
        let finishAddCommentPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let finishEditCommentPreset = PassthroughSubject<Void, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var text: String?
    }
    
    struct Config {
        let commentPreset: CommentPresetResponse?
    }
    
    enum Route {
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let reviewRepository: ReviewRepository
        let sharedRepository: SharedRepository
        let preference: Preference
        
        init(
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            sharedRepository: SharedRepository = SharedRepositoryImpl(),
            preference: Preference = Preference.shared
        ) {
            self.reviewRepository = reviewRepository
            self.sharedRepository = sharedRepository
            self.preference = preference
        }
    }
}

final class AddCommentPresetBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        let isEnableAddButton = config.commentPreset?.body.isEmpty.isNot ?? false
        self.output = Output(commentPreset: config.commentPreset, isEnableAddButton: .init(isEnableAddButton))
        self.state = State(text: config.commentPreset?.body)
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.inputText
            .withUnretained(self)
            .sink { (owner: AddCommentPresetBottomSheetViewModel, text: String?) in
                owner.state.text = text
                owner.updateButtonEnable()
            }
            .store(in: &cancellables)
        
        input.didTapAdd
            .withUnretained(self)
            .sink { (owner: AddCommentPresetBottomSheetViewModel, _) in
                if let commentPreset = owner.output.commentPreset {
                    owner.editCommentPreset(commentPreset: commentPreset)
                } else {
                    owner.addCommentPreset()
                }
            }
            .store(in: &cancellables)
        
        input.didTapClose
            .subscribe(output.finishEditCommentPreset)
            .store(in: &cancellables)
    }
    
    private func updateButtonEnable() {
        if let text = state.text, !text.isEmpty {
            output.isEnableAddButton.send(true)
        } else {
            output.isEnableAddButton.send(false)
        }
    }
    
    private func addCommentPreset() {
        guard let text = state.text, !text.isEmpty else { return }
        let input = CommentPresetCreateRequest(body: text)
        
        Task {
            do {
                let storeId = dependency.preference.storeId
                let nonceToken = try await dependency.sharedRepository.createNonce(input: NonceCreateRequest()).get().nonce
                let response = try await dependency.reviewRepository.addCommentPreset(nonceToken: nonceToken, storeId: storeId, input: input).get()
                
                output.finishAddCommentPreset.send(response)
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func editCommentPreset(commentPreset: CommentPresetResponse) {
        guard let text = state.text, !text.isEmpty else { return }
        let input = CommentPresetPatchRequest(body: text)

        Task {
            let storeId = dependency.preference.storeId
            let result = await dependency.reviewRepository.editCommentPreset(storeId: storeId, commentPresetId: commentPreset.presetId, input: input)
            
            switch result {
            case .success:
                output.finishEditCommentPreset.send(())
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}
