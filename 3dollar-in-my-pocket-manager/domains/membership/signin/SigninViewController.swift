import UIKit

import ReactorKit


final class SigninViewController: BaseViewController, View, SigninCoordinator {
    private let signinView = SigninView()
    private let signinReactor = SigninReactor(
        kakaoManager: KakaoSignInManager.shared,
        appleSignInManager: AppleSigninManager.shared,
        authService: AuthService()
    )
    private weak var coordinator: SigninCoordinator?
    
    static func instance() -> UINavigationController {
        let viewController = SigninViewController(nibName: nil, bundle: nil)
        
        return UINavigationController(rootViewController: viewController)
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
            .asDriver(onErrorJustReturn: (.apple, ""))
            .drive { [weak self] (socialType, token) in
                self?.coordinator?.pushSignup(socialType: socialType, token: token)
            }
            .disposed(by: self.eventDisposeBag)
        
        self.signinReactor.pushWaitingPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.pushWaiting()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.signinReactor.goToMainPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.goToMain()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: SigninReactor) {
        // Bind Action
        self.signinView.appleButton.rx.tap
            .map { Reactor.Action.tapSignInButton(socialType: .apple) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signinView.kakaoButton.rx.tap
            .map { Reactor.Action.tapSignInButton(socialType: .kakao) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signinView.naverButton.rx.tap
            .map { Reactor.Action.tapSignInButton(socialType: .naver) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
}
