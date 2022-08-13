import RxSwift
import RxCocoa
import ReactorKit

final class EditIntroductionReactor: BaseReactor, Reactor {
    enum Action {
        case inputText(String?)
        case tapEditButton
    }
    
    enum Mutation {
        case setIntroduction(String?)
        case setEditButtonEnable(Bool)
        case pop
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var store: Store
        var isEditButtonEnable: Bool
    }
    
    let initialState: State
    let popupPublisher = PublishRelay<Void>()
    private let storeService: StoreServiceType
    private let globalState: GlobalState
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(
        store: Store,
        storeService: StoreServiceType,
        globlaState: GlobalState,
        analyticsManager: AnalyticsManagerProtocol
    ) {
        self.storeService = storeService
        self.globalState = globlaState
        self.analyticsManager = analyticsManager
        self.initialState = State(
            store: store,
            isEditButtonEnable: !(store.introduction ?? "").isEmpty
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputText(let text):
            return .merge([
                .just(.setIntroduction(text)),
                .just(.setEditButtonEnable(text?.isEmpty == false))
            ])
            
        case .tapEditButton:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.updateStore(store: self.currentState.store),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setIntroduction(let introduction):
            newState.store.introduction = introduction
            
        case .setEditButtonEnable(let isEnable):
            newState.isEditButtonEnable = isEnable
            
        case .pop:
            self.popupPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func updateStore(store: Store) -> Observable<Mutation> {
        return self.storeService.updateStore(store: store)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.globalState.updateStorePublisher.onNext(store)
                self.analyticsManager.sendEvent(event: .editStoreIntroduction(
                    storeId: self.currentState.store.id,
                    screen: .editIntroduction
                ))
            })
            .map { _ in Mutation.pop }
            .catch {
                return .merge([
                    .just(.showLoading(isShow: false)),
                    .just(.showErrorAlert($0))
                ])
            }
    }
}
