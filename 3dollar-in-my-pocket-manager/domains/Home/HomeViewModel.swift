import CoreLocation
import Combine

extension HomeViewModel {
    enum Constant {
        static let aroundDistance = 1
        static let defaultLocation = CLLocation(latitude: 37.497941, longitude: 127.027616)
        
        /// 가게를 오픈할 수 있는 현재 위치와의 최대 거리
        static let maximumOpenDistance: Double = 100
    }
    
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let viewWillAppear = PassthroughSubject<Void, Never>()
        let didTapShowOtherStore = PassthroughSubject<Void, Never>()
        let didTapCurrentLocation = PassthroughSubject<Void, Never>()
        let didTapSalesToggle = PassthroughSubject<Void, Never>()
        let moveCamera = PassthroughSubject<CLLocation, Never>()
        let didTapOperationSetting = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screen: ScreenName = .home
        let address = CurrentValueSubject<String, Never>("")
        let isShowOtherStore = CurrentValueSubject<Bool, Never>(false)
        let myLocation = CurrentValueSubject<CLLocation?, Never>(nil)
        let cameraLocation = CurrentValueSubject<CLLocation?, Never>(nil)
        let store = CurrentValueSubject<BossStoreResponse?, Never>(nil)
        let aroundStores = PassthroughSubject<[BossStoreSimpleResponse], Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var isAutoOpen: Bool = false
    }
    
    struct Dependency {
        let mapRepository: MapRepository
        let storeRepository: StoreRepository
        let preferenceRepository: PreferenceRepository
        let locationManager: CLLocationManager
        var preference: Preference
        let logManager: LogManagerProtocol
        
        init(
            mapRepository: MapRepository = MapRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            preferenceRepository: PreferenceRepository = PreferenceRepositoryImpl(),
            locationManager: CLLocationManager = CLLocationManager(),
            preference: Preference = Preference.shared,
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.mapRepository = mapRepository
            self.storeRepository = storeRepository
            self.preferenceRepository = preferenceRepository
            self.locationManager = locationManager
            self.preference = preference
            self.logManager = logManager
        }
    }
    
    enum Route {
        case showInvalidPositionAlert
        case showErrorAlert(Error)
        case pushOperationSetting
        case presentAutoAlert
    }
}

final class HomeViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
        bind()
    }
    
    private func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.fetchCurrentLocation()
                owner.fetchMyStoreInfo()
            }
            .store(in: &cancellables)
        
        input.didTapCurrentLocation
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.fetchCurrentLocation()
            }
            .store(in: &cancellables)
        
        input.didTapShowOtherStore
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                let showOtherStore = !owner.output.isShowOtherStore.value
                owner.sendClickShowOtherStoreEvent(showOtherStore: showOtherStore)
                owner.output.isShowOtherStore.send(showOtherStore)
                
                if showOtherStore, let myLocation = owner.output.myLocation.value {
                    owner.fetchAroundStores(location: myLocation)
                } else {
                    owner.output.aroundStores.send([])
                }
            }
            .store(in: &cancellables)
        
        input.didTapSalesToggle
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                if let store = owner.output.store.value,
                   store.openStatus.status == .open {
                    
                    if owner.state.isAutoOpen {
                        owner.output.route.send(.presentAutoAlert)
                    } else {
                        owner.closeStore()
                    }
                } else {
                    if owner.isInRightPosition() {
                        owner.openStore()
                    } else {
                        owner.output.route.send(.showInvalidPositionAlert)
                    }
                }
            }
            .store(in: &cancellables)
        
        input.moveCamera
            .withUnretained(self)
            .sink { (owner: HomeViewModel, location: CLLocation) in
                owner.output.cameraLocation.send(location)
                if owner.output.isShowOtherStore.value {
                    owner.fetchAroundStores(location: location)
                }
            }
            .store(in: &cancellables)
        
        input.didTapOperationSetting
            .map { Route.pushOperationSetting }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.viewWillAppear
            .dropFirst()
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.fetchPreference()
            }
            .store(in: &cancellables)
    }
    
    private func fetchCurrentLocation() {
        Task {
            do {
                let location = try await dependency.locationManager.requestLocation()
                
                output.cameraLocation.send(location)
                output.myLocation.send(location)
                fetchAddress(location: location)
            } catch {
                output.route.send(.showErrorAlert(error))
                output.cameraLocation.send(Constant.defaultLocation)
                output.myLocation.send(Constant.defaultLocation)
                fetchAddress(location: Constant.defaultLocation)
            }
        }
    }
    
    private func fetchAddress(location: CLLocation) {
        Task {
            let result = await dependency.mapRepository.searchAddress(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            switch result {
            case .success(let address):
                output.address.send(address)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func fetchMyStoreInfo() {
        Task {
            let result = await dependency.storeRepository.fetchMyStore()
            
            switch result {
            case .success(let storeInfo):
                output.store.send(storeInfo)
                dependency.preference.storeId = storeInfo.bossStoreId
                dependency.preference.storeName = storeInfo.name
                fetchPreference()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func fetchAroundStores(location: CLLocation) {
        Task {
            let result = await dependency.storeRepository.fetchAroundStores(location: location, distance: Constant.aroundDistance)
            
            switch result {
            case .success(let stores):
                output.aroundStores.send(stores)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func fetchPreference() {
        Task {
            let result = await dependency.preferenceRepository.fetchPreference(storeId: dependency.preference.storeId)
            
            switch result {
            case .success(let preference):
                state.isAutoOpen = preference.autoOpenCloseControl
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func closeStore() {
        Task { [weak self] in
            guard let self, var store = output.store.value else { return }
            
            let result = await dependency.storeRepository.closeStore(storeId: store.bossStoreId)
            
            switch result {
            case .success:
                store.openStatus.status = .closed
                output.store.send(store)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func isInRightPosition() -> Bool {
        guard let myLocation = output.myLocation.value,
              let cameraLocation = output.cameraLocation.value else { return false }
        
        return cameraLocation.distance(from: myLocation) <= Constant.maximumOpenDistance
    }
    
    private func openStore() {
        Task { [weak self] in
            guard let self,
                  var store = output.store.value,
                  let openLocation = output.cameraLocation.value else { return }
            
            let result = await dependency.storeRepository.openStore(storeId: store.bossStoreId, location: openLocation)
            
            switch result {
            case .success:
                store.location = LocationResponse(
                    latitude: openLocation.coordinate.latitude,
                    longitude: openLocation.coordinate.longitude
                )
                store.openStatus.status = .open
                store.openStatus.openStartDateTime = DateUtils.toString(date: Date())
                output.store.send(store)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}

// MARK: Log
extension HomeViewModel {
    private func sendClickShowOtherStoreEvent(showOtherStore: Bool) {
        dependency.logManager.sendEvent(.init(
            screen: output.screen,
            eventName: .showOtherBoss,
            extraParameters: [.isOn: showOtherStore]
        ))
    }
}
