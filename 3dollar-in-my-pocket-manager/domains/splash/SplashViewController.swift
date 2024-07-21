import UIKit

import ReactorKit
import RxRelay

final class SplashViewController: BaseViewController, View, SplashCoordinator {
    private let splashView = SplashView()
    private let splashReactor = SplashReactor(
        authService: AuthService(),
        feedbackService: FeedbackService(),
        userDefaultsUtils: UserDefaultsUtils(),
        context: SharedContext.shared
    )
    private weak var coordinator: SplashCoordinator?
    private let finishLottiePublisher = PublishRelay<Void>()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> SplashViewController {
        return SplashViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.splashView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.splashReactor
        self.coordinator = self
        self.splashReactor.action.onNext(.viewDidLoad)
        self.splashView.startLottie { [weak self] in
            self?.finishLottiePublisher.accept(())
        }
    }
    
    override func bindEvent() {
        Observable.zip([
            self.splashReactor.goToSigninPublisher,
            self.finishLottiePublisher
        ])
        .asDriver(onErrorJustReturn: [])
        .drive(onNext: { [weak self] _ in
            self?.coordinator?.goToSignin()
        })
        .disposed(by: self.eventDisposeBag)
        
        Observable.zip([
            self.splashReactor.goToWaitingPublisher,
            self.finishLottiePublisher
        ])
        .asDriver(onErrorJustReturn: [])
        .drive(onNext: { [weak self] _ in
            self?.coordinator?.goToWaiting()
        })
        .disposed(by: self.eventDisposeBag)
        
        Observable.zip([
            self.splashReactor.goToMainPublisher,
            self.finishLottiePublisher
        ])
        .asDriver(onErrorJustReturn: [])
        .drive(onNext: { [weak self] _ in
            self?.coordinator?.goToMain()
        })
        .disposed(by: self.eventDisposeBag)
        
        self.splashReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: SplashReactor) { }
}
