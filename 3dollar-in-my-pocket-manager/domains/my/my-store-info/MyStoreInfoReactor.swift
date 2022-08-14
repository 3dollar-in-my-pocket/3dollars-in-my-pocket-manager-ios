import ReactorKit
import RxSwift
import RxCocoa

final class MyStoreInfoReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case refresh
        case tapEditStoreInfo
        case tapEditIntroduction
        case tapEditMenus
        case tapEditSchedule
    }
    
    enum Mutation {
        case setStore(Store)
        case updateIntorudction(String)
        case pushEditStoreInfo(store: Store)
        case pushEditIntroduction(store: Store)
        case pushEditMenus(store: Store)
        case pushEditSchedule(store: Store)
        case showErrorAlert(Error)
    }
    
    struct State {
        var store = Store()
    }
    
    let initialState = State()
    let pushEditStoreInfoPublisher = PublishRelay<Store>()
    let pushEditIntroductionPublisher = PublishRelay<Store>()
    let pushEditMenuPublisher = PublishRelay<Store>()
    let pushEditSchedulePublisher = PublishRelay<Store>()
    private let storeService: StoreServiceType
    private let globalState: GlobalState
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(
        storeService: StoreServiceType,
        globalState: GlobalState,
        analyticsManager: AnalyticsManagerProtocol
    ) {
        self.storeService = storeService
        self.globalState = globalState
        self.analyticsManager = analyticsManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            self.analyticsManager.sendEvent(event: .viewScreen(.myStoreInfo))
            return self.fetchMyStore()
            
        case .refresh:
            return self.fetchMyStore()
            
        case .tapEditStoreInfo:
            self.analyticsManager.sendEvent(event: .tapEditStoreInfo(
                storeId: self.currentState.store.id,
                screen: .myStoreInfo
            ))
            return .just(.pushEditStoreInfo(store: self.currentState.store))
            
        case .tapEditIntroduction:
            self.analyticsManager.sendEvent(event: .tapEditIntroduction(
                storeId: self.currentState.store.id,
                screen: .myStoreInfo
            ))
            return .just(.pushEditIntroduction(store: self.currentState.store))
            
        case .tapEditMenus:
            self.analyticsManager.sendEvent(event: .tapEditMenu(
                storeId: self.currentState.store.id,
                screen: .myStoreInfo
            ))
            return .just(.pushEditMenus(store: self.currentState.store))
            
        case .tapEditSchedule:
            self.analyticsManager.sendEvent(event: .tapEditSchedule(
                storeId: self.currentState.store.id,
                screen: .myStoreInfo
            ))
            return .just(.pushEditSchedule(store: self.currentState.store))
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge([
            mutation,
            self.globalState.updateStorePublisher
                .map { .setStore($0) }
        ])
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStore(let store):
            newState.store = store
            
        case .updateIntorudction(let introduction):
            newState.store.introduction = introduction
            
        case .pushEditStoreInfo(let store):
            self.pushEditStoreInfoPublisher.accept(store)
            
        case .pushEditIntroduction(let store):
            self.pushEditIntroductionPublisher.accept(store)
            
        case .pushEditMenus(let store):
            self.pushEditMenuPublisher.accept(store)
            
        case .pushEditSchedule(let store):
            self.pushEditSchedulePublisher.accept(store)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func fetchMyStore() -> Observable<Mutation> {
        return self.storeService.fetchMyStore()
            .map { .setStore(Store(response: $0)) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
