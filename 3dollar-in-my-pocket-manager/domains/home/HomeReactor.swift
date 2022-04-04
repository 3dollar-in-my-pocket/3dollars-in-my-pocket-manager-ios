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
        case setCameraPosition(CLLocation)
        case toggleSalesStatus
        case showErrorAlert(Error)
    }
    
    struct State {
        var isOnSales = false
        var isShowOtherStore = true
        var cameraPosition: CLLocation?
    }
    
    let initialState = State()
    private let locationManager: LocationManagerProtocol
    
    init(locationManager: LocationManagerProtocol) {
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
            .map { .setCameraPosition($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
