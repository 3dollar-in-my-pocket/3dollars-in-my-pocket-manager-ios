import UIKit
import CoreLocation

import ReactorKit

final class HomeViewController: BaseViewController, View, HomeCoordinator {
    private let homeView = HomeView()
    private let homeReactor = HomeReactor(
        mapService: MapService(),
        storeService: StoreService(),
        locationManager: LocationManager.shared
    )
    private weak var coordinator: HomeCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    static func instance() -> HomeViewController {
        return HomeViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_home"),
                tag: TabBarTag.home.rawValue
            )
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
    }
    
    override func loadView() {
        self.view = self.homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.homeReactor
        self.homeReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.homeReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: HomeReactor) {
        // Bind action
        self.homeView.salesToggleView.rx.tapButton
            .map { Reactor.Action.tapSalesToggle }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind state
        reactor.state
            .map { $0.address }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(self.homeView.addressView.rx.address)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.store?.isOpen }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.homeView.salesToggleView.rx.isOn)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.cameraPosition }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: CLLocation(
                latitude: 127.044155,
                longitude: 37.547980
            ))
            .drive(self.homeView.rx.cameraPosition)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.store }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Store())
            .drive(self.homeView.rx.myStore)
            .disposed(by: self.disposeBag)
    }
}
