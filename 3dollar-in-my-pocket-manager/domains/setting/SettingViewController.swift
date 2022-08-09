import UIKit

import Base
import ReactorKit

final class SettingViewController: BaseViewController, View, SettingCoordinator {
    private let settingView = SettingView()
    let settingReactor = SettingReactor(
        authService: AuthService(),
        deviceService: DeviceService(),
        userDefaults: UserDefaultsUtils()
    )
    private weak var coordinator: SettingCoordinator?
    
    static func instance() -> UINavigationController {
        let viewController = SettingViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_my"),
                tag: TabBarTag.setting.rawValue
            )
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        self.view = self.settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.settingReactor
        self.coordinator = self
        self.settingReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.settingView.tableView.rx.itemSelected
            .filter { $0.row == 1 }
            .map { _ in () }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToKakaoTalkChannel()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingView.tableView.rx.itemSelected
            .filter { $0.row == 2 }
            .map { _ in () }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.pushFAQ()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingReactor.goToSigninPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToSignin()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingReactor.showCopyTokenSuccessAlertPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.showCopyTokenSuccessAlert()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingReactor.showLoadginPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingView.tableFooterView.signoutButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.showSignoutAlert()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: SettingReactor) {
        // Bind Action
        self.settingView.fcmTokenButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapFCMToken }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.user }
            .distinctUntilChanged()
            .map { SettingCellType.toSettingCellTypes(user: $0) }
            .asDriver(onErrorJustReturn: [])
            .drive(self.settingView.tableView.rx.items(
                cellIdentifier: SettingTableViewCell.registerId,
                cellType: SettingTableViewCell.self
            )) { row, cellType, cell in
                cell.bind(cellType: cellType)
                cell.rightButton.rx.tap
                    .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .drive(onNext: { [weak self] in
                        self?.coordinator?.showLogoutAlert()
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.rightSwitch.rx.controlEvent(.valueChanged)
                    .withLatestFrom(cell.rightSwitch.rx.value)
                    .map { Reactor.Action.tapNotificationSwitch(isEnable: $0) }
                    .bind(to: self.settingReactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: self.eventDisposeBag)
        
        reactor.state
            .map { $0.user.name }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(self.settingView.tableHeaderView.rx.name)
            .disposed(by: self.disposeBag)
    }
}
