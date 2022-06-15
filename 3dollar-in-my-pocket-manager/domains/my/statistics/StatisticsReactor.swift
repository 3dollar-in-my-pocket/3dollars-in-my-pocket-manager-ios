import ReactorKit
import RxRelay

final class StatisticsReactor: Reactor {
    enum Action {
        case updateTotalReviewCount(Int)
        case refresh
        case tapFilterButton(StatisticsFilterButton.FilterType)
    }
    
    enum Mutation {
        case setTotalReviewCount(Int)
        case setTab(StatisticsFilterButton.FilterType)
        case refresh(StatisticsFilterButton.FilterType)
    }
    
    struct State {
        var totalReviewCount: Int
        var selectedFilter: StatisticsFilterButton.FilterType
    }
    
    let initialState: State
    let refreshPublisher = PublishRelay<StatisticsFilterButton.FilterType>()
    
    init(state: State = State(
        totalReviewCount: 0,
        selectedFilter: .total
    )) {
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateTotalReviewCount(let totalReviewCount):
            return .just(.setTotalReviewCount(totalReviewCount))
            
        case .tapFilterButton(let filterType):
            return .just(.setTab(filterType))
            
        case .refresh:
            return .just(.refresh(self.currentState.selectedFilter))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTotalReviewCount(let totalReviewCount):
            newState.totalReviewCount = totalReviewCount
            
        case .setTab(let filterType):
            newState.selectedFilter = filterType
            
        case .refresh(let filterType):
            self.refreshPublisher.accept(filterType)
        }
        
        return newState
    }
}
