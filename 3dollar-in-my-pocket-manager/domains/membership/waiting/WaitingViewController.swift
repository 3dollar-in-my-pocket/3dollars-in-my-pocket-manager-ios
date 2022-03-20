import UIKit
import MessageUI

import ReactorKit

final class WaitingViewController: BaseViewController, View, WaitingCoordinator {
    private let waitingView = WaitingView()
    private let waitingReactor = WaitingReactor()
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
    }
    
    func bind(reactor: WaitingReactor) {
        // Bind action
        self.waitingView.questionButton.rx.tap
            .map { Reactor.Action.tapQuestionButton }
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
