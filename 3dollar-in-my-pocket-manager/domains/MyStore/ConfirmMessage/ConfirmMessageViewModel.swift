import Combine

extension ConfirmMessageViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapSend = PassthroughSubject<Void, Never>()
        let didTapReWrite = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .messageConfirmDialog
        let storeName: String
        let message: String
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let toast = PassthroughSubject<String, Never>()
        
        // 이벤트 전달용
        let didSendedMessage = PassthroughSubject<StoreMessageCreateResponse, Never>()
        let didTapRewrite = PassthroughSubject<String, Never>()
    }
    
    struct State {
        var nonceToken: String?
    }
    
    struct Config {
        let message: String
    }
    
    enum Route {
        case dismiss
    }
    
    struct Dependency {
        let messageRepository: MessageRepository
        let sharedRepository: SharedRepository
        let logManager: LogManagerProtocol
        let preference: Preference
        
        init(
            messageRepository: MessageRepository = MessageRepositoryImpl(),
            sharedRepository: SharedRepository = SharedRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = Preference.shared
        ) {
            self.messageRepository = messageRepository
            self.sharedRepository = sharedRepository
            self.logManager = logManager
            self.preference = preference
        }
    }
}

final class ConfirmMessageViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state = State()
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(storeName: dependency.preference.storeName, message: config.message)
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: ConfirmMessageViewModel, _) in
                owner.createNonceToken()
            }
            .store(in: &cancellables)
        
        input.didTapSend
            .withUnretained(self)
            .sink { (owner: ConfirmMessageViewModel, _) in
                owner.sendMessage()
            }
            .store(in: &cancellables)
        
        input.didTapReWrite
            .withUnretained(self)
            .sink { (owner: ConfirmMessageViewModel, _) in
                owner.output.route.send(.dismiss)
                owner.output.didTapRewrite.send(owner.output.message)
            }
            .store(in: &cancellables)
    }
    
    private func createNonceToken() {
        Task {
            let nonceResult = await dependency.sharedRepository.createNonce(input: .init())
            
            switch nonceResult {
            case .success(let response):
                state.nonceToken = response.nonce
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func sendMessage() {
        guard let nonceToken = state.nonceToken else { return }
        Task {
            let input = StoreMessageCreateRequest(
                storeId: dependency.preference.storeId,
                body: output.message,
                nonceToken: nonceToken
            )
            let result = await dependency.messageRepository.sendMessage(input: input)
            
            switch result {
            case .success(let response):
                output.didSendedMessage.send(response)
                output.toast.send(Strings.Message.Toast.finish)
                output.route.send(.dismiss)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}
