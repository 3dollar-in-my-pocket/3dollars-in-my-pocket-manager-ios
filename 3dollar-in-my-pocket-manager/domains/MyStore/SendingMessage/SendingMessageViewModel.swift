import Combine

extension SendingMessageViewModel {
    enum Constant {
        static let minimumLength = 10
        static let maximumLength = 100
    }
    
    struct Input {
        let inputText = PassthroughSubject<String, Never>()
        let didTapSend = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let state = PassthroughSubject<SendingMessageTextView.State, Never>()
        let didSendedMessage = PassthroughSubject<StoreMessageResponse, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let toast = PassthroughSubject<String, Never>()
    }
    
    struct State {
        var message = ""
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

final class SendingMessageViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    var state = State()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.inputText
            .withUnretained(self)
            .sink { (owner: SendingMessageViewModel, inputText: String) in
                owner.handleInputText(inputText)
            }
            .store(in: &cancellables)
        
        input.didTapSend
            .withUnretained(self)
            .sink { (owner: SendingMessageViewModel, _) in
                guard owner.validateMessageLength() else {
                    owner.output.state.send(.warning)
                    return
                }
                owner.sendMessage()
            }
            .store(in: &cancellables)
    }
    
    private func handleInputText(_ inputText: String) {
        state.message = inputText
    }
    
    private func validateMessageLength() -> Bool {
        return state.message.count >= Constant.minimumLength && state.message.count <= Constant.maximumLength
    }
    
    private func sendMessage() {
        Task {
            let input = StoreMessageCreateRequest(storeId: dependency.preference.storeId, body: state.message)
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
