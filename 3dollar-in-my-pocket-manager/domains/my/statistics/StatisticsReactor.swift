import ReactorKit
import RxRelay

final class StatisticsReactor: Reactor {
    enum Action {
        case refresh
        case tapFilterButton(StatisticsFilterButton.FilterType)
    }
    
    enum Mutation {
        case updateReviewCount(Int)
        case setTab(StatisticsFilterButton.FilterType)
        case refresh(StatisticsFilterButton.FilterType)
    }
    
    struct State {
        var totalReviewCount: Int
        var selectedFilter: StatisticsFilterButton.FilterType
    }
    
    let initialState: State
    let refreshPublisher = PublishRelay<StatisticsFilterButton.FilterType>()
    private let globalState: GlobalState
    
    init(
        globalState: GlobalState,
        state: State = State(
        totalReviewCount: 0,
        selectedFilter: .total
    )) {
        self.globalState = globalState
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapFilterButton(let filterType):
            return .just(.setTab(filterType))
            
        case .refresh:
            return .just(.refresh(self.currentState.selectedFilter))
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge([
            mutation,
            self.globalState.updateReviewCountPublisher
                .map { .updateReviewCount($0) }
        ])
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateReviewCount(let totalReviewCount):
            newState.totalReviewCount = totalReviewCount
            
        case .setTab(let filterType):
            newState.selectedFilter = filterType
            
        case .refresh(let filterType):
            self.refreshPublisher.accept(filterType)
        }
        
        return newState
    }
}
