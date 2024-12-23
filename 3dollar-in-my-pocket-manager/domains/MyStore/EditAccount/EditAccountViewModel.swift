import Combine

extension EditAccountViewModel {
    struct Input {
        let inputName = PassthroughSubject<String, Never>()
        let inputAccountNumber = PassthroughSubject<String, Never>()
        let inputBank = PassthroughSubject<BossBank, Never>()
        let didTapBank = PassthroughSubject<Void, Never>()
        let didTapSave = PassthroughSubject<Void, Never>()
        let didTapDeleteAccountNumber = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let store: CurrentValueSubject<BossStoreResponse, Never>
        let updatedStore = PassthroughSubject<BossStoreResponse, Never>()
        let isEnableSaveButton = CurrentValueSubject<Bool, Never>(false)
        let showLoading = PassthroughSubject<Bool, Never>()
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var store: BossStoreResponse
    }
    
    enum Route {
        case pop
        case showErrorAlert(Error)
        case presentBankBottomSheet(BankListBottomSheetViewModel)
        case presentDeleteAccountNumberDialog(DeleteAccountViewModel)
    }
    
    struct Config {
        let store: BossStoreResponse
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let bankRepository: BankRepository
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            bankRepository: BankRepository = BankRepositoryImpl()
        ) {
            self.storeRepository = storeRepository
            self.bankRepository = bankRepository
        }
    }
}

final class EditAccountViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let config: Config
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(store: .init(config.store))
        self.state = State(store: config.store)
        self.config = config
        self.dependency = dependency
        
        super.init()
        createAccountIfNeeded()
        bind()
    }
    
    private func createAccountIfNeeded() {
        guard state.store.accountNumbers.isEmpty else { return }
        state.store.accountNumbers.append(BossStoreAccountNumber(
            bank: BossBank(key: "", description: ""),
            accountHolder: "",
            accountNumber: "",
            description: nil
        ))
    }
    
    private func bind() {
        input.inputName
            .withUnretained(self)
            .sink { (owner: EditAccountViewModel, name: String) in
                owner.handleName(name)
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.inputAccountNumber
            .withUnretained(self)
            .sink { (owner: EditAccountViewModel, number: String) in
                owner.handleNumber(number)
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.inputBank
            .withUnretained(self)
            .sink { (owner: EditAccountViewModel, bank: BossBank) in
                owner.handleBank(bank)
                owner.output.store.send(owner.state.store)
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.didTapBank
            .withUnretained(self)
            .sink { (owner: EditAccountViewModel, _) in
                owner.presentBankList()
            }
            .store(in: &cancellables)
        
        input.didTapSave
            .withUnretained(self)
            .sink { (owner: EditAccountViewModel, _) in
                owner.updateStore()
            }
            .store(in: &cancellables)
        
        input.didTapDeleteAccountNumber
            .withUnretained(self)
            .sink { (owner: EditAccountViewModel, _) in
                owner.presentDeleteAccountNumberDialog()
            }
            .store(in: &cancellables)
    }
    
    private func handleName(_ name: String) {
        guard state.store.accountNumbers.first.isNotNil else { return }
        state.store.accountNumbers[0].accountHolder = name
    }
    
    private func handleNumber(_ number: String) {
        guard state.store.accountNumbers.first.isNotNil else { return }
        state.store.accountNumbers[0].accountNumber = number
    }
    
    private func handleBank(_ bank: BossBank) {
        guard state.store.accountNumbers.first.isNotNil else { return }
        state.store.accountNumbers[0].bank = bank
    }
    
    private func updateSaveButtonEnable() {
        guard let accountInfo = state.store.accountNumbers.first else { return }
        let isEnable = accountInfo.accountHolder.isNotEmpty && accountInfo.accountNumber.isNotEmpty
        output.isEnableSaveButton.send(isEnable)
    }
    
    private func presentBankList() {
        Task {
            output.showLoading.send(true)
            let result = await dependency.bankRepository.fetchBankList()
            switch result {
            case .success(let bankList):
                let config = BankListBottomSheetViewModel.Config(
                    selectedBank: state.store.accountNumbers.first?.bank,
                    bankList: bankList
                )
                let viewModel = BankListBottomSheetViewModel(config: config)
                
                bindBankListBottomSheetViewModel(viewModel)
                output.route.send(.presentBankBottomSheet(viewModel))
                break
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
            output.showLoading.send(false)
        }
    }
    
    private func bindBankListBottomSheetViewModel(_ viewModel: BankListBottomSheetViewModel) {
        viewModel.output.finishSelectBank
            .subscribe(input.inputBank)
            .store(in: &viewModel.cancellables)
    }
    
    private func updateStore() {
        output.showLoading.send(true)
        Task { [weak self] in
            guard let self else { return }
            
            let request = state.store.toPatchRequest()
            let result = await dependency.storeRepository.editStore(storeId: state.store.bossStoreId, request: request)
            
            switch result {
            case .success(_):
                output.showLoading.send(false)
                output.updatedStore.send(state.store)
                output.toast.send("정보가 업데이트 되었습니다")
                output.route.send(.pop)
            case .failure(let error):
                output.showLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func presentDeleteAccountNumberDialog() {
        let viewModel = DeleteAccountViewModel()
        
        viewModel.output.successDeleteAccountNumber
            .withUnretained(self)
            .sink(receiveValue: { (owner: EditAccountViewModel, _) in
                owner.state.store.accountNumbers = []
                owner.output.updatedStore.send(owner.state.store)
                owner.output.route.send(.pop)
            })
            .store(in: &viewModel.cancellables)
        output.route.send(.presentDeleteAccountNumberDialog(viewModel))
    }
}
