import RxSwift
import RxCocoa
import ReactorKit

final class BankListBottomSheetReactor: BaseReactor, Reactor {
    typealias Item = (bank: Bank, isSelected: Bool)
    
    enum Action {
        case didSelectItem(Int)
    }
    
    enum Mutation {
        case selectBank(Bank)
        case route(Route)
    }
    
    struct State {
        var selectedBank: Bank?
        var itemList: [Item]
        @Pulse var route: Route?
    }
    
    enum Route {
        case pop
    }
    
    struct Config {
        let selectedBank: Bank?
        let bankList: [Bank]
    }
    
    struct Relay {
        let selectBank = PublishRelay<Bank>()
    }
    
    let initialState: State
    let relay = Relay()
    
    init(config: Config) {
        let itemList: [Item] = config.bankList.map {
            return (bank: $0, isSelected: $0 == config.selectedBank)
        }
        
        self.initialState = State(selectedBank: config.selectedBank, itemList: itemList)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didSelectItem(let index):
            guard let bank = currentState.itemList[safe: index]?.bank else { return .empty() }
            
            return .merge([
                .just(.selectBank(bank)),
                .just(.route(.pop))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .selectBank(let bank):
            relay.selectBank.accept(bank)
            
        case .route(let route):
            newState.route = route
        }
        
        return newState
    }
}
