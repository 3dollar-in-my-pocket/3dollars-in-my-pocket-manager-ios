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
        let screenName: ScreenName = .messageSendingBottomSheet
        let firstMessage: String
        let state = PassthroughSubject<SendingMessageTextView.State, Never>()
        let route = PassthroughSubject<Route, Never>()
        
        // 이벤트 전달용
        let didTapSend = PassthroughSubject<String, Never>()
    }
    
    struct State {
        var message: String
    }
    
    struct Config {
        let message: String
    }
    
    enum Route {
        case dismiss
    }
}

final class SendingMessageViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    
    init(config: Config) {
        self.output = Output(firstMessage: config.message)
        self.state = State(message: config.message)
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
                
                owner.output.route.send(.dismiss)
                owner.output.didTapSend.send(owner.state.message)
            }
            .store(in: &cancellables)
    }
    
    private func handleInputText(_ inputText: String) {
        state.message = inputText
    }
    
    private func validateMessageLength() -> Bool {
        return state.message.count >= Constant.minimumLength && state.message.count <= Constant.maximumLength
    }
}
