import UIKit
import MessageUI

import ReactorKit

final class WaitingViewController: BaseViewController, View, WaitingCoordinator {
    private let waitingView = WaitingView()
    private let waitingReactor = WaitingReactor(
        authService: AuthService(),
        userDefaults: UserDefaultsUtils()
    )
    private weak var coordinator: WaitingCoordinator?
    
    static func instance() -> WaitingViewController {
        return WaitingViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.waitingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.waitingReactor
    }
    
    override func bindEvent() {
        self.waitingReactor.presentMailComposerPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: {[weak self] message in
                self?.coordinator?.showMailComposer(message: message)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.waitingReactor.goToSigninPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToSignin()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.waitingReactor.showLoadginPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.waitingReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: WaitingReactor) {
        // Bind action
        self.waitingView.questionButton.rx.tap
            .map { Reactor.Action.tapQuestionButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.waitingView.logoutButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapLogout }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
}

extension WaitingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}
