import Combine

extension AddCommentPresetBottomSheetViewModel {
    struct Input {
        let inputText = PassthroughSubject<String?, Never>()
        let didTapAdd = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let isEnableAddButton = CurrentValueSubject<Bool, Never>(false)
        let finishAddCommentPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var text: String?
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
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
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
                owner.addCommentPreset()
            }
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
}
