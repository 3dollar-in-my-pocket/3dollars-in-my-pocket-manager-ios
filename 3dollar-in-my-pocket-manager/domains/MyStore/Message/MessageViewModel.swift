import Combine

extension MessageViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapSendingMessage = PassthroughSubject<Void, Never>()
        let willDisplay = PassthroughSubject<Int, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        
        // From SendingMessage
        let didTapSendingMessageFromBottomSheet = PassthroughSubject<String, Never>()
        
        // From ConfirmMessage
        let didSendedMessage = PassthroughSubject<StoreMessageCreateResponse, Never>()
        let didTapRewrite = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .message
        let buttonState = PassthroughSubject<(StoreMessagePolicyResponse, Int), Never>()
        let datasource = PassthroughSubject<[MessageSection], Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
        let isRefreshing = CurrentValueSubject<Bool, Never>(false)
    }
    
    struct State {
        var subscriberCount: Int = 0
        var messages: [StoreMessageResponse] = []
        var cursor: String?
        var hasMore: Bool = true
    }
    
    enum Route {
        case sendingMessage(SendingMessageViewModel)
        case confirmMessage(ConfirmMessageViewModel)
    }
    
    struct Dependency {
        let messageRepository: MessageRepository
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol
        let preference: Preference
        
        init(
            messageRepository: MessageRepository = MessageRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = Preference.shared
        ) {
            self.messageRepository = messageRepository
            self.storeRepository = storeRepository
            self.logManager = logManager
            self.preference = preference
        }
    }
}

final class MessageViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    private var task: Task<Void, Never>?
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
        bindSendingMessageBottomSheet()
        bindConfirmMessageDialog()
    }
    
    private func bind() {
        Publishers.Merge(input.firstLoad, input.refresh)
            .withUnretained(self)
            .sink { (owner: MessageViewModel, _) in
                owner.state.messages.removeAll()
                owner.state.cursor = nil
                owner.state.hasMore = true
                owner.state.subscriberCount = 0
                owner.firstLoadDatas()
            }
            .store(in: &cancellables)
        
        input.didTapSendingMessage
            .withUnretained(self)
            .sink { (owner: MessageViewModel, _) in
                owner.presentSendingMessage()
            }
            .store(in: &cancellables)
        
        input.willDisplay
            .withUnretained(self)
            .sink { (owner: MessageViewModel, index: Int) in
                guard owner.canLoadMore(index: index) else { return }
                
                owner.loadMoreMessages()
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
        input.didSendedMessage
            .withUnretained(self)
            .sink { (owner: MessageViewModel, response: StoreMessageCreateResponse) in
                owner.state.messages.insert(response.message, at: 0)
                owner.output.buttonState.send((response.policy, owner.state.subscriberCount))
                owner.updateDataSource()
            }
            .store(in: &cancellables)
        
        input.didTapRewrite
            .withUnretained(self)
            .sink { (owner: MessageViewModel, message: String) in
                owner.presentSendingMessage(message: message)
            }
            .store(in: &cancellables)
    }
    
    private func firstLoadDatas() {
        Task {
            let storeResult = await dependency.storeRepository.fetchMyStore()
            let messageResult = await dependency.messageRepository.fetchMessages(storeId: dependency.preference.storeId, cursor: nil)
            
            switch storeResult {
            case .success(let response):
                state.subscriberCount = response.favorite.subscriberCount
            case .failure(let error):
                output.showErrorAlert.send(error)
                output.isRefreshing.send(false)
                return
            }
            
            switch messageResult {
            case .success(let response):
                state.cursor = response.messages.cursor.nextCursor
                state.hasMore = response.messages.cursor.hasMore
                state.messages = response.messages.contents
                output.buttonState.send((response.policy, state.subscriberCount))
            case .failure(let error):
                output.showErrorAlert.send(error)
                output.isRefreshing.send(false)
                return
            }
            
            updateDataSource()
            output.isRefreshing.send(false)
        }
    }
    
    private func loadMoreMessages() {
        task?.cancel()
        task = Task {
            let messageResult = await dependency.messageRepository.fetchMessages(storeId: dependency.preference.storeId, cursor: state.cursor)
            
            switch messageResult {
            case .success(let response):
                state.cursor = response.messages.cursor.nextCursor
                state.hasMore = response.messages.cursor.hasMore
                state.messages.append(contentsOf: response.messages.contents)
                updateDataSource()
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func updateDataSource() {
        if state.messages.isEmpty {
            if state.subscriberCount == 0 {
                output.datasource.send([.init(type: .first, items: [.toast, .firstTitle, .bookmark, .introduction])])
            } else {
                output.datasource.send([.init(type: .noHistory, items: [.overview(subscriberCount: state.subscriberCount), .introduction])])
            }
        } else {
            var sections: [MessageSection] = []
            sections.append(MessageSection(type: .overview, items: [.overview(subscriberCount: state.subscriberCount)]))
            
            let messageItems = state.messages.map { MessageSectionItem.message($0) }
            sections.append(MessageSection(type: .message, items: messageItems))
            
            output.datasource.send(sections)
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return state.hasMore && state.cursor.isNotNil && (index >= state.messages.count - 1)
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
