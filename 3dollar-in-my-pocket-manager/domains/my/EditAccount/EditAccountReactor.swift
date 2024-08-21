import Combine

import RxSwift
import RxCocoa
import ReactorKit

extension EditAccountViewModel {
    struct Input {
        let inputName = PassthroughSubject<String, Never>()
        let inputAccountName = PassthroughSubject<String, Never>()
        let inputBank = PassthroughSubject<BankResponse, Never>()
        let didTapBank = PassthroughSubject<Void, Never>()
        let didTapSave = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let store: CurrentValueSubject<BossStoreResponse, Never>
        let updatedStore = PassthroughSubject<BossStoreResponse, Never>()
        let isEnableSaveButton = CurrentValueSubject<Bool, Never>(false)
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var store: BossStoreResponse
    }
    
    enum Route {
        case pop
        case presentBankBottomSheet(BankListBottomSheetReactor)
    }
    
    struct Config {
        let store: BossStoreResponse
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let bankRepository:
    }
    
    
}

final class EditAccountViewModel: BaseViewModel {
    
}

final class EditAccountReactor: BaseReactor, Reactor {
    enum Action {
        case inputName(String)
        case inputAccountNumber(String)
        case inputBank(Bank)
        case didTapBank
        case didTapSave
    }
    
    enum Mutation {
        case setName(String)
        case setAccountNumber(String)
        case setBank(Bank)
        case enableSaveButton(Bool)
        case route(Route)
        case showErrorAlert(Error)
    }
    
    struct State {
        var name: String?
        var bank: Bank?
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
        case presentBankBottomSheet(BankListBottomSheetReactor)
    }
    
    struct Config {
        let store: Store
    }
    
    let initialState: State
    let relay = Relay()
    private let storeService: StoreServiceType
    private let bankService: BankServiceType
    
    init(
        store: Store,
        storeService: StoreServiceType = StoreService(),
        bankService: BankServiceType = BankService()
    ) {
        var isEnableSaveButton: Bool
        if let name = store.accountInfos.first?.holder,
           let accountNumber = store.accountInfos.first?.number,
           let bank = store.accountInfos.first?.bank {
            isEnableSaveButton = !name.isEmpty && !accountNumber.isEmpty && !bank.description.isEmpty
        } else {
            isEnableSaveButton = false
        }
        
        self.initialState = State(
            name: store.accountInfos.first?.holder,
            bank: store.accountInfos.first?.bank,
            accountNumber: store.accountInfos.first?.number,
            isEnableSaveButton: isEnableSaveButton,
            store: store
        )
        self.storeService = storeService
        self.bankService = bankService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputName(let name):
            let isEnableSaveButton = isEnableSaveButton(
                name: name,
                accountNumber: currentState.accountNumber,
                bank: currentState.bank
            )
            
            return .merge([
                .just(.setName(name)),
                .just(.enableSaveButton(isEnableSaveButton))
            ])
            
        case .inputAccountNumber(let accountNumber):
            let isEnableSaveButton = isEnableSaveButton(
                name: currentState.name,
                accountNumber: accountNumber,
                bank: currentState.bank
            )
            
            return .merge([
                .just(.enableSaveButton(isEnableSaveButton)),
                .just(.setAccountNumber(accountNumber))
            ])
            
        case .inputBank(let bank):
            let isEnableSaveButton = isEnableSaveButton(
                name: currentState.name,
                accountNumber: currentState.accountNumber,
                bank: bank
            )
            
            return .merge([
                .just(.enableSaveButton(isEnableSaveButton)),
                .just(.setBank(bank))
            ])
            
        case .didTapBank:
            return fetchBankList()
                .compactMap({ [weak self] bankList -> Mutation? in
                    guard let self else { return nil }
                    
                    return routeBankListBottomSheet(bankList: bankList, selectedBank: currentState.bank)
                })
                .catch {
                    return .just(.showErrorAlert($0))
                }
            
        case .didTapSave:
            return updateStore(store: currentState.store)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setName(let name):
            newState.name = name
            
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
    
    private func isEnableSaveButton(
        name: String?,
        accountNumber: String?,
        bank: Bank?
    ) -> Bool {
        guard let name, let accountNumber, let bank else { return false }
        
        return !name.isEmpty && !accountNumber.isEmpty && !bank.description.isEmpty
    }
    
    private func updateStore(store: Store) -> Observable<Mutation> {
        guard let name = currentState.name,
              let bank = currentState.bank,
              let number = currentState.accountNumber else { return .empty() }
        
        let accountInfo = AccountInfo(bank: bank, number: number, holder: name)
        var store = currentState.store
        store.accountInfos = [accountInfo]
        
        return storeService.updateStore(store: store)
            .do(onNext: { [weak self] _ in
                self?.relay.onSuccessUpdateAccountInfo.accept(accountInfo)
            })
            .map { _ in .route(Route.pop) }
            .catch { error in
                return .just(Mutation.showErrorAlert(error))
            }
    }
    
    private func fetchBankList() -> Observable<[Bank]> {
        return bankService.fetchBankList()
            .map { $0.map { Bank(response: $0) } }
    }
    
    private func routeBankListBottomSheet(bankList: [Bank], selectedBank: Bank?) -> Mutation {
        let config = BankListBottomSheetReactor.Config(selectedBank: selectedBank, bankList: bankList)
        let reactor = BankListBottomSheetReactor(config: config)
        
        reactor.relay.selectBank
            .map { Action.inputBank($0) }
            .bind(to: action)
            .disposed(by: reactor.relayDisposeBag)
        
        return .route(.presentBankBottomSheet(reactor))
    }
}
