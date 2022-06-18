import ReactorKit

final class FAQReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setFAQs([FAQ])
        case showErrorAlert(Error)
    }
    
    struct State {
        var faqs: [FAQ]
    }
    
    let initialState: State
    private let faqService: FAQServiceType
    
    init(
        state: State = State(faqs: []),
        faqService: FAQServiceType
    ) {
        self.faqService = faqService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchFAQs()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setFAQs(let faqs):
            newState.faqs = faqs
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func fetchFAQs() -> Observable<Mutation> {
        return self.faqService.fetchFAQs()
            .map { $0.map(FAQ.init(response:)) }
            .map { .setFAQs($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
