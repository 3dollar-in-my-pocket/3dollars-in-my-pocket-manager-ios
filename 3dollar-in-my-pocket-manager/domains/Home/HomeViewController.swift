import UIKit
import CoreLocation

import CombineCocoa

import ReactorKit
import NMapsMap

final class HomeViewController: BaseViewController {
    private let homeView = HomeView()
    private let viewModel: HomeViewModel
    
    override var screenName: ScreenName {
        return viewModel.output.screen
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "ic_home"),
            tag: TabBarTag.home.rawValue
        )
        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        homeView.mapView.addCameraDelegate(delegate: self)
        viewModel.input.firstLoad.send(())
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        homeView.showOtherButton.tapGesture.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.didTapShowOtherStore)
            .store(in: &cancellables)
        
        homeView.currentLocationButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapCurrentLocation)
            .store(in: &cancellables)
        
        homeView.salesToggleView.toggleButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSalesToggle)
            .store(in: &cancellables)
        
        homeView.operationSettingButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapOperationSetting)
            .store(in: &cancellables)
    }
    
    private func bindOutput() {
        viewModel.output.address
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, address: String) in
                owner.homeView.bindAddress(address)
            }
            .store(in: &cancellables)
        
        viewModel.output.isShowOtherStore
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, showOtherStore: Bool) in
                owner.homeView.bindShowOtherStores(showOtherStore)
            }
            .store(in: &cancellables)
        
        viewModel.output.myLocation
            .compactMap { $0 }
            .removeDuplicates()
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, location: CLLocation) in
                owner.homeView.moveCameraPosition(location: location)
                owner.homeView.setupAvailableArea(location: location)
            }
            .store(in: &cancellables)
        
        viewModel.output.cameraLocation
            .compactMap { $0 }
            .removeDuplicates()
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, location: CLLocation) in
                owner.homeView.moveCameraPosition(location: location)
            }
            .store(in: &cancellables)
        
        viewModel.output.store
            .compactMap { $0 }
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, store: BossStoreResponse) in
                owner.homeView.bindStore(store)
            }
            .store(in: &cancellables)
        
        viewModel.output.aroundStores
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, stores: [BossStoreSimpleResponse]) in
                owner.homeView.bindOtherStores(stores)
            }
            .store(in: &cancellables)
        
        viewModel.output.store
            .compactMap { $0?.openStatus.status == .open }
            .removeDuplicates()
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, isOpen: Bool) in
                owner.homeView.salesToggleView.bindStatus(isOn: isOpen)
            }
            .store(in: &cancellables)
        
        viewModel.output.store
            .compactMap { $0?.openStatus.openStartDateTime }
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, openStartTime: String) in
                let startDate = DateUtils.toDate(dateString: openStartTime)
                owner.homeView.salesToggleView.bindTimer(startDate: startDate)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, route: HomeViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: HomeViewModel.Route) {
        switch route {
        case .showInvalidPositionAlert:
            showInvalidPositionAlert()
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .pushOperationSetting:
            pushPreference()
        case .presentAutoAlert:
            presentAutoAlert()
        }
    }
    
    private func showInvalidPositionAlert() {
        AlertUtils.showWithAction(
            viewController: self,
            title: nil,
            message: "home_invalid_position".localized,
            okbuttonTitle: "common_ok".localized,
            onTapOk: nil
        )
    }
    
    private func pushPreference() {
        let viewController = PreferenceViewController()
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentAutoAlert() {
        let viewController = HomeAutoAlertViewController { [weak self] in
            self?.pushPreference()
        }
        
        tabBarController?.present(viewController, animated: true)
    }
}

extension HomeViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        guard reason == NMFMapChangedByGesture && animated  else { return }
        let mapLocation = CLLocation(
            latitude: mapView.cameraPosition.target.lat,
            longitude: mapView.cameraPosition.target.lng
        )
        
        viewModel.input.moveCamera.send(mapLocation)
    }
}
