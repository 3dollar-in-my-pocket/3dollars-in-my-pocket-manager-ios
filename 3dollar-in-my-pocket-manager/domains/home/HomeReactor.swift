import CoreLocation

import ReactorKit
import RxSwift
import RxCocoa

final class HomeReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapSalesToggle
        case moveCamera(CLLocation)
    }
    
    enum Mutation {
        case setAddress(String)
        case setStore(Store)
        case setCameraPosition(CLLocation)
        case setStoreLocation(CLLocation)
        case toggleSalesStatus
        case showErrorAlert(Error)
    }
    
    struct State {
        var address = ""
        var isShowOtherStore = true
        var cameraPosition: CLLocation?
        var store: Store?
    }
    
    let initialState = State()
    private let mapService: MapServiceProtocol
    private let storeSerivce: StoreServiceProtocol
    private let locationManager: LocationManagerProtocol
    private let backgroundTaskManager: BackgroundTaskManagerProtocol
    
    init(
        mapService: MapServiceProtocol,
        storeService: StoreServiceProtocol,
        locationManager: LocationManagerProtocol,
        backgroundTaskManager: BackgroundTaskManagerProtocol
    ) {
        self.mapService = mapService
        self.storeSerivce = storeService
        self.locationManager = locationManager
        self.backgroundTaskManager = backgroundTaskManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .merge([
                self.fetchCurrentLocation(),
                self.fetchMyStoreInfo()
            ])
            
        case .tapSalesToggle:
            if self.currentState.store?.isOpen == true {
                self.backgroundTaskManager.cancelBackgroundTask()
                return self.closeStore()
            } else {
                self.backgroundTaskManager.registerBackgroundTask()
                return self.openStore()
            }
            
        case .moveCamera(let position):
            return .just(.setCameraPosition(position))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAddress(let address):
            newState.address = address
            
        case .setStore(let store):
            newState.store = store
            
        case .setCameraPosition(let location):
            newState.cameraPosition = location
            
        case .setStoreLocation(let location):
            newState.store?.location = location
            
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
}
