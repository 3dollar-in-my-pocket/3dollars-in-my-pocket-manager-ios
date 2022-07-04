import CoreLocation

import ReactorKit
import RxSwift
import RxCocoa

final class HomeReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapShowOtherStore
        case tapCurrentLocation
        case tapSalesToggle
        case moveCamera(CLLocation)
    }
    
    enum Mutation {
        case setAddress(String)
        case setStore(Store)
        case setAroundStores([Store])
        case setShowOtherStore(Bool)
        case setInitialPosition(CLLocation)
        case setCameraPosition(CLLocation)
        case setStoreLocation(CLLocation)
        case setStoreOpenTime(Date)
        case toggleSalesStatus
        case showInvalidPositionAlert
        case showErrorAlert(Error)
    }
    
    struct State {
        var address = ""
        var isShowOtherStore = false
        var initialPosition: CLLocation?
        var cameraPosition: CLLocation?
        var store: Store?
        var aroundStores: [Store] = []
    }
    
    let initialState = State()
    let showInvalidPositionAlertPublisher = PublishRelay<Void>()
    private let mapService: MapServiceProtocol
    private let storeSerivce: StoreServiceType
    private let locationManager: LocationManagerProtocol
    private var userDefaults: UserDefaultsUtils
    
    init(
        mapService: MapServiceProtocol,
        storeService: StoreServiceType,
        locationManager: LocationManagerProtocol,
        userDefaults: UserDefaultsUtils
    ) {
        self.mapService = mapService
        self.storeSerivce = storeService
        self.locationManager = locationManager
        self.userDefaults = userDefaults
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .merge([
                self.fetchCurrentLocationForInitilize(),
                self.fetchMyStoreInfo()
            ])
            
        case .tapCurrentLocation:
            if self.currentState.store?.isOpen == true {
                return self.fetchCurrentLocation()
            } else {
                return self.fetchCurrentLocationForInitilize()
            }
            
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
                return self.closeStore()
            } else {
                if self.isInRightPosition() {
                    return self.openStore()
                } else {
                    return .just(.showInvalidPositionAlert)
                }
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
            
        case .setInitialPosition(let location):
            newState.initialPosition = location
            
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
            
        case .showInvalidPositionAlert:
            self.showInvalidPositionAlertPublisher.accept(())
            
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
    
    private func fetchCurrentLocationForInitilize() -> Observable<Mutation> {
        return self.locationManager.getCurrentLocation()
            .flatMap{ [weak self] currentLocation -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return .merge([
                    .just(.setCameraPosition(currentLocation)),
                    .just(.setInitialPosition(currentLocation)),
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
    
    private func isInRightPosition() -> Bool {
        guard let currentPosition = self.currentState.cameraPosition,
              let initialPosition = self.currentState.initialPosition else {
            return false
        }
        
        return currentPosition.distance(from: initialPosition) <= 100
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
