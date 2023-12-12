import RxSwift
import RxCocoa
import ReactorKit

final class EditAccountReactor: BaseReactor, Reactor {
    enum Action {
        case inputAccountNumber(String)
        case inputBank(String)
        case didTapBank
        case didTapSave
    }
    
    enum Mutation {
        case setAccountNumber(String)
        case setBank(String)
        case enableSaveButton(Bool)
        case route(Route)
        case showErrorAlert(Error)
    }
    
    struct State {
        var bank: String?
        var accountNumber: String?
        var isEnableSaveButton = false
        var store: Store
        @Pulse var route: Route?
    }
    
    struct Relay {
        let onSuccessUpdateAccountInfo = PublishRelay<AccountInfo>()
    }
    
    enum Route {
        case pop
        case presentBankBottomSheet
    }
    
    let initialState: State
    let relay = Relay()
    private let storeService: StoreServiceType
    
    init(
        store: Store,
        storeService: StoreServiceType = StoreService()
    ) {
        self.initialState = State(store: store)
        self.storeService = storeService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputAccountNumber(let accountNumber):
            let isEnableSaveButton = isEnableSaveButton(accountNumber: currentState.accountNumber, bank: accountNumber)
            
            return .merge([
                .just(.enableSaveButton(isEnableSaveButton)),
                .just(.setAccountNumber(accountNumber))
            ])
            
        case .inputBank(let bank):
            let isEnableSaveButton = isEnableSaveButton(accountNumber: currentState.accountNumber, bank: bank)
            
            return .merge([
                .just(.enableSaveButton(isEnableSaveButton)),
                .just(.setBank(bank))
            ])
            
        case .didTapBank:
            return .just(.route(.presentBankBottomSheet))
            
        case .didTapSave:
            return updateStore(store: currentState.store)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAccountNumber(let accountNumber):
            newState.accountNumber = accountNumber
            
        case .setBank(let bank):
            newState.bank = bank
            
        case .enableSaveButton(let isEnable):
            newState.isEnableSaveButton = isEnable
            
        case .route(let route):
            newState.route = route
            
        case .showErrorAlert(let error):
            showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func isEnableSaveButton(accountNumber: String?, bank: String?) -> Bool {
        guard let accountNumber, let bank else { return false }
        
        return !accountNumber.isEmpty && !bank.isEmpty
    }
    
    private func updateStore(store: Store) -> Observable<Mutation> {
        guard let bank = currentState.bank,
              let number = currentState.accountNumber else { return .empty() }
        
        let accountInfo = AccountInfo(bank: bank, number: number)
        var store = currentState.store
        store.accountInfo = accountInfo
        
        return storeService.updateStore(store: store)
            .do(onNext: { [weak self] _ in
                self?.relay.onSuccessUpdateAccountInfo.accept(accountInfo)
            })
            .map { _ in .route(Route.pop) }
            .catch { error in
                return .just(Mutation.showErrorAlert(error))
            }
    }
}
