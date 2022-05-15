import CoreLocation

import ReactorKit
import RxSwift
import RxCocoa

final class HomeReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapShowOtherStore
        case tapSalesToggle
        case moveCamera(CLLocation)
    }
    
    enum Mutation {
        case setAddress(String)
        case setStore(Store)
        case setAroundStores([Store])
        case setShowOtherStore(Bool)
        case setCameraPosition(CLLocation)
        case setStoreLocation(CLLocation)
        case setStoreOpenTime(Date)
        case toggleSalesStatus
        case showErrorAlert(Error)
    }
    
    struct State {
        var address = ""
        var isShowOtherStore = false
        var cameraPosition: CLLocation?
        var store: Store?
        var aroundStores: [Store] = []
    }
    
    let initialState = State()
    private let mapService: MapServiceProtocol
    private let storeSerivce: StoreServiceType
    private let locationManager: LocationManagerProtocol
    private let backgroundTaskManager: BackgroundTaskManagerProtocol
    private var userDefaults: UserDefaultsUtils
    
    init(
        mapService: MapServiceProtocol,
        storeService: StoreServiceType,
        locationManager: LocationManagerProtocol,
        backgroundTaskManager: BackgroundTaskManagerProtocol,
        userDefaults: UserDefaultsUtils
    ) {
        self.mapService = mapService
        self.storeSerivce = storeService
        self.locationManager = locationManager
        self.backgroundTaskManager = backgroundTaskManager
        self.userDefaults = userDefaults
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .merge([
                self.fetchCurrentLocation(),
                self.fetchMyStoreInfo()
            ])
            
        case .tapShowOtherStore:
            if self.currentState.isShowOtherStore {
                return .merge([
                    .just(.setAroundStores([])),
                    .just(.setShowOtherStore(false))
                ])
            } else {
                if let cameraPosition = self.currentState.cameraPosition {
                    return .merge([
                        self.fetchAroundStores(location: cameraPosition),
                        .just(.setShowOtherStore(true))
                    ])
                } else {
                    return .just(.setShowOtherStore(true))
                }
            }
            
        case .tapSalesToggle:
            if self.currentState.store?.isOpen == true {
                self.backgroundTaskManager.cancelBackgroundTask()
                return self.closeStore()
            } else {
                self.backgroundTaskManager.scheduleBackgroundTask()
                return self.openStore()
            }
            
        case .moveCamera(let position):
            if self.currentState.isShowOtherStore {
                return .merge([
                    .just(.setCameraPosition(position)),
                    self.fetchAroundStores(location: position)
                ])
            } else {
                return .just(.setCameraPosition(position))
            }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAddress(let address):
            newState.address = address
            
        case .setStore(let store):
            newState.store = store
            
        case .setShowOtherStore(let isShow):
            newState.isShowOtherStore = isShow
            
        case .setAroundStores(let stores):
            newState.aroundStores = stores
            
        case .setCameraPosition(let location):
            newState.cameraPosition = location
            
        case .setStoreLocation(let location):
            newState.store?.location = location
            
        case .setStoreOpenTime(let date):
            newState.store?.openTime = date
            
        case .toggleSalesStatus:
            newState.store?.isOpen.toggle()
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func fetchCurrentLocation() -> Observable<Mutation> {
        return self.locationManager.getCurrentLocation()
            .flatMap{ [weak self] currentLocation -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return .merge([
                    .just(.setCameraPosition(currentLocation)),
                    self.searchAddress(location: currentLocation)
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func searchAddress(location: CLLocation) -> Observable<Mutation> {
        return self.mapService.searchAddress(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        .map { .setAddress($0) }
        .catch { .just(.showErrorAlert($0)) }
    }
    
    private func fetchMyStoreInfo() -> Observable<Mutation> {
        return self.storeSerivce.fetchMyStore()
            .map(Store.init(response:))
            .do(onNext: { [weak self] store in
                self?.userDefaults.storeId = store.id
            })
            .map { .setStore($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func openStore() -> Observable<Mutation> {
        guard let storeId = self.currentState.store?.id,
              let location = self.currentState.cameraPosition else { return .empty() }
        
        return self.storeSerivce.openStore(storeId: storeId, location: location)
            .flatMap { _ -> Observable<Mutation> in
                return .merge([
                    .just(.setStoreLocation(location)),
                    .just(.setStoreOpenTime(Date())),
                    .just(.toggleSalesStatus),
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func closeStore() -> Observable<Mutation> {
        guard let storeId = self.currentState.store?.id else { return .empty() }
        
        return self.storeSerivce.closeStore(storeId: storeId)
            .map { _ in .toggleSalesStatus }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func fetchAroundStores(location: CLLocation) -> Observable<Mutation> {
        return self.storeSerivce.fetchAroundStores(location: location, distance: 1)
            .map { $0.map(Store.init) }
            .map { Mutation.setAroundStores($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
