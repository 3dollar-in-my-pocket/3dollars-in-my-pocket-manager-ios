import Combine

extension MessageViewModel {
    struct Input {
        let didTapSendingMessage = PassthroughSubject<Void, Never>()
        
        // From SendingMessage
        let didTapSendingMessageFromBottomSheet = PassthroughSubject<String, Never>()
        
        // From ConfirmMessage
        let didSendedMessage = PassthroughSubject<StoreMessageResponse, Never>()
        let didTapRewrite = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case sendingMessage(SendingMessageViewModel)
        case confirmMessage(ConfirmMessageViewModel)
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

final class MessageViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
        bindSendingMessageBottomSheet()
        bindConfirmMessageDialog()
    }
    
    private func bind() {
        input.didTapSendingMessage
            .withUnretained(self)
            .sink { (owner: MessageViewModel, _) in
                owner.presentSendingMessage()
            }
            .store(in: &cancellables)
    }
    
    private func bindSendingMessageBottomSheet() {
        input.didTapSendingMessageFromBottomSheet
            .withUnretained(self)
            .sink { (owner: MessageViewModel, message: String) in
                owner.presentConfirmMessage(message: message)
            }
            .store(in: &cancellables)
    }
    
    private func bindConfirmMessageDialog() {
//        input.didSendedMessage
        
        input.didTapRewrite
            .withUnretained(self)
            .sink { (owner: MessageViewModel, message: String) in
                owner.presentSendingMessage(message: message)
            }
            .store(in: &cancellables)
    }
    
    private func presentSendingMessage(message: String = "") {
        let config = SendingMessageViewModel.Config(message: message)
        let viewModel = SendingMessageViewModel(config: config)
        
        viewModel.output.didTapSend
            .subscribe(input.didTapSendingMessageFromBottomSheet)
            .store(in: &viewModel.cancellables)
        output.route.send(.sendingMessage(viewModel))
    }
    
    private func presentConfirmMessage(message: String) {
        let config = ConfirmMessageViewModel.Config(message: message)
        let viewModel = ConfirmMessageViewModel(config: config)
        
        viewModel.output.didSendedMessage
            .subscribe(input.didSendedMessage)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.didTapRewrite
            .subscribe(input.didTapRewrite)
            .store(in: &cancellables)
        
        output.route.send(.confirmMessage(viewModel))
    }
}
