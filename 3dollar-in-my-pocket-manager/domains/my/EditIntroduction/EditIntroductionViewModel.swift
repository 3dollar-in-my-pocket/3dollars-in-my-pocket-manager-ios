import Combine

import RxSwift
import RxCocoa
import ReactorKit

extension EditIntroductionViewModel {
    struct Input {
        let inputText = PassthroughSubject<String?, Never>()
        let didTapEdit = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .editIntroduction
        let store: CurrentValueSubject<BossStoreInfoResponse, Never>
        let updatedStore = PassthroughSubject<BossStoreInfoResponse, Never>()
        let isEditButtonEnable = CurrentValueSubject<Bool, Never>(false)
        let toast = PassthroughSubject<String, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var store: BossStoreInfoResponse
    }
    
    struct Config {
        let store: BossStoreInfoResponse
    }
    
    enum Route {
        case pop
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.storeRepository = storeRepository
            self.logManager = logManager
        }
    }
}

final class EditIntroductionViewModel: BaseViewModel {
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
        bind()
    }
    
    private func bind() {
        input.inputText
            .withUnretained(self)
            .sink { (owner: EditIntroductionViewModel, introduction: String?) in
                owner.state.store.introduction = introduction
                owner.updateEditButtonEnable()
            }
            .store(in: &cancellables)
        
        input.didTapEdit
            .withUnretained(self)
            .sink { (owner: EditIntroductionViewModel, _) in
                owner.editStoreInfo()
            }
            .store(in: &cancellables)
    }
    
    private func editStoreInfo() {
        Task {
            output.showLoading.send(true)
            let result = await dependency.storeRepository.editStore(
                storeId: state.store.bossStoreId,
                request: state.store.toPatchRequest()
            )
            
            switch result {
            case .success(_):
                sendEditIntroductionLog()
                output.updatedStore.send(state.store)
                output.toast.send("edit_introduction.toast.success_update".localized)
                output.route.send(.pop)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
            output.showLoading.send(false)
        }
    }
    
    private func updateEditButtonEnable() {
        let isNotEmpty = state.store.introduction?.isNotEmpty ??  false
        let isEnable = state.store != config.store && isNotEmpty
        
        output.isEditButtonEnable.send(isEnable)
    }
}

// MARK: Log
extension EditIntroductionViewModel {
    func sendEditIntroductionLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .editStoreIntroduction,
            extraParameters: [.storeId: state.store.bossStoreId]
        ))
    }
}
