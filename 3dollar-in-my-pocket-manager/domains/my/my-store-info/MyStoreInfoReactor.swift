import ReactorKit
import RxSwift
import RxCocoa

final class MyStoreInfoReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapEditStoreInfo
        case tapEditIntroduction
        case tapEditMenus
        case tapEditSchedule
    }
    
    enum Mutation {
        case setStore(Store)
        case pushEditStoreInfo(store: Store)
        case pushEditIntroduction(storeId: String, introduction: String?)
        case pushEditMenus
        case pushEditSchedule
        case showErrorAlert(Error)
    }
    
    struct State {
        var store = Store()
    }
    
    let initialState = State()
    let pushEditStoreInfoPublisher = PublishRelay<Store>()
    let pushEditIntroductionPublisher = PublishRelay<(String, String?)>()
    private let storeService: StoreServiceProtocol
    
    init(storeService: StoreServiceProtocol) {
        self.storeService = storeService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchMyStore()
            
        case .tapEditStoreInfo:
            return .just(.pushEditStoreInfo(store: self.currentState.store))
            
        case .tapEditIntroduction:
            return .just(.pushEditIntroduction(
                storeId: self.currentState.store.id,
                introduction: self.currentState.store.introduction
            ))
            
        case .tapEditMenus:
            return .empty()
            
        case .tapEditSchedule:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStore(let store):
            newState.store = store
            
        case .pushEditStoreInfo(let store):
            self.pushEditStoreInfoPublisher.accept(store)
            
        case .pushEditIntroduction(let storeId, let introduction):
            self.pushEditIntroductionPublisher.accept((storeId, introduction))
            
        case .pushEditMenus:
            break
            
        case .pushEditSchedule:
            break
            
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
