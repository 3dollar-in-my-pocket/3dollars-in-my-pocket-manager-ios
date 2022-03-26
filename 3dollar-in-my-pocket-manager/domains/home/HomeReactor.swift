import ReactorKit
import RxSwift
import RxCocoa

final class HomeReactor: Reactor {
    enum Action {
        case tapSalesToggle
    }
    
    enum Mutation {
        case toggleSalesStatus
    }
    
    struct State {
        var isOnSales = false
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapSalesToggle:
            return .just(.toggleSalesStatus)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .toggleSalesStatus:
            newState.isOnSales.toggle()
        }
        
        return newState
    }
}
