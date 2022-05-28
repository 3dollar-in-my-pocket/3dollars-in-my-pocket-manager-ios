import ReactorKit

final class StatisticsReactor: Reactor {
    enum Action {
        case updateTotalReviewCount(Int)
        case tapFilterButton(StatisticsFilterButton.FilterType)
    }
    
    enum Mutation {
        case setTotalReviewCount(Int)
        case setTab(StatisticsFilterButton.FilterType)
    }
    
    struct State {
        var totalReviewCount: Int
        var selectedFilter: StatisticsFilterButton.FilterType
        
    }
    
    let initialState: State
    
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTotalReviewCount(let totalReviewCount):
            newState.totalReviewCount = totalReviewCount
            
        case .setTab(let filterType):
            newState.selectedFilter = filterType
        }
        
        return newState
    }
}
