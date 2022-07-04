import UIKit

import Base
import ReactorKit

final class SplashViewController: BaseViewController, View, SplashCoordinator {
    private let splashView = SplashView()
    private let splashReactor = SplashReactor(
        authService: AuthService(),
        feedbackService: FeedbackService(),
        userDefaultsUtils: UserDefaultsUtils(),
        context: Context.shared
    )
    private weak var coordinator: SplashCoordinator?
    
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
    }
    
    override func bindEvent() {
        self.splashReactor.goToSigninPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToSignin()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.splashReactor.goToWaitingPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToWaiting()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.splashReactor.goToMainPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
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
