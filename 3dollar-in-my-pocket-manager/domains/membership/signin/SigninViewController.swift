import UIKit

import ReactorKit

final class SigninViewController: BaseViewController, View, SigninCoordinator {
    private let signinView = SigninView()
    private let signinReactor = SigninReactor(
        kakaoManager: KakaoSignInManager.shared,
        appleSignInManager: AppleSigninManager.shared,
        authService: AuthService(),
        logManager: .shared
    )
    private weak var coordinator: SigninCoordinator?
    override var screenName: ScreenName {
        return .signin
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> UINavigationController {
        let viewController = SigninViewController(nibName: nil, bundle: nil)
        
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
        }
    }
    
    override func loadView() {
        self.view = self.signinView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.signinReactor
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.signinReactor.pushSignUpPublisher
            .asDriver(onErrorJustReturn: (.apple, "", nil))
            .drive { [weak self] (socialType, token, name) in
                self?.coordinator?.pushSignup(socialType: socialType, token: token, name: name)
            }
            .disposed(by: self.eventDisposeBag)
        
        self.signinReactor.goToWaitingPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.goToWaiting()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.signinReactor.goToMainPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.goToMain()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.signinReactor.showLoadginPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.signinReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: SigninReactor) {
        // Bind Action
        signinView.introImageButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapLogo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.signinView.appleButton.rx.tap
            .map { Reactor.Action.tapSignInButton(socialType: .apple) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signinView.kakaoButton.rx.tap
            .map { Reactor.Action.tapSignInButton(socialType: .kakao) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .withUnretained(self)
            .bind { (owner: SigninViewController, route: SigninReactor.Route) in
                owner.handleRoute(route)
            }
            .disposed(by: disposeBag)
    }
    
    private func handleRoute(_ route: SigninReactor.Route) {
        switch route {
        case .presentCodeAlert:
            presentCodeAlert()
        }
    }
    
    private func presentCodeAlert() {
        let alert = UIAlertController(title: String(localized: "code_alert.title"), message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: String(localized: "common.ok"), style: .default) { [weak self] ok in
            guard let code = alert.textFields?.first?.text else { return }
            
            self?.reactor?.action.onNext(.signinDemo(code: code))
        }
        let cancel = UIAlertAction(title: String(localized: "common.cancel"), style: .cancel)
        alert.addTextField()
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}
