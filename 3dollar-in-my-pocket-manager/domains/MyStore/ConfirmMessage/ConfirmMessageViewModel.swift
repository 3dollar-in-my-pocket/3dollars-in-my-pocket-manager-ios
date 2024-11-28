import Combine

extension ConfirmMessageViewModel {
    struct Input {
        let didTapSend = PassthroughSubject<Void, Never>()
        let didTapReWrite = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let storeName: String
        let message: String
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let toast = PassthroughSubject<String, Never>()
        
        // 이벤트 전달용
        let didSendedMessage = PassthroughSubject<StoreMessageResponse, Never>()
        let didTapRewrite = PassthroughSubject<String, Never>()
    }
    
    struct Config {
        let message: String
    }
    
    enum Route {
        case dismiss
    }
    
    struct Dependency {
        let messageRepository: MessageRepository
        let logManager: LogManagerProtocol
        let preference: Preference
        
        init(
            messageRepository: MessageRepository = MessageRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = Preference.shared
        ) {
            self.messageRepository = messageRepository
            self.logManager = logManager
            self.preference = preference
        }
    }
}

final class ConfirmMessageViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(storeName: dependency.preference.storeName, message: config.message)
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
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
    
    private func sendMessage() {
        Task {
            let input = StoreMessageCreateRequest(storeId: dependency.preference.storeId, body: output.message)
            let result = await dependency.messageRepository.sendMessage(input: input)
            
            switch result {
            case .success(let messageResponse):
                output.didSendedMessage.send(messageResponse)
                output.toast.send(Strings.Message.Toast.finish)
                output.route.send(.dismiss)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}
