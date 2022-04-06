import CoreLocation

import ReactorKit
import RxSwift
import RxCocoa

final class HomeReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapSalesToggle
    }
    
    enum Mutation {
        case setAddress(String)
        case setCameraPosition(CLLocation)
        case toggleSalesStatus
        case showErrorAlert(Error)
    }
    
    struct State {
        var address = ""
        var isOnSales = false
        var isShowOtherStore = true
        var cameraPosition: CLLocation?
    }
    
    let initialState = State()
    private let mapService: MapServiceProtocol
    private let locationManager: LocationManagerProtocol
    
    init(
        mapService: MapServiceProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.mapService = mapService
        self.locationManager = locationManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchCurrentLocation()
            
        case .tapSalesToggle:
            return .just(.toggleSalesStatus)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAddress(let address):
            newState.address = address
            
        case .setCameraPosition(let location):
            newState.cameraPosition = location
            
        case .toggleSalesStatus:
            newState.isOnSales.toggle()
            
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
}
