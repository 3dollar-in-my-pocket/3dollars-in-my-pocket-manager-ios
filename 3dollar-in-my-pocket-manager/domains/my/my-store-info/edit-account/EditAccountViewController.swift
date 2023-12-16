import UIKit

import RxSwift
import ReactorKit

final class EditAccountViewController: BaseViewController, View, EditAccountCoordinator {
    private let editAccountView = EditAccountView()
    private weak var coordinator: EditAccountCoordinator?
    
    init(reactor: EditAccountReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = editAccountView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        editAccountView.backButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: eventDisposeBag)
        
        reactor?.showErrorAlert
            .bind(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: eventDisposeBag)
    }
    
    func bind(reactor: EditAccountReactor) {
        // Bind Action
        editAccountView.nameInputField.rx.text
            .map { Reactor.Action.inputName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editAccountView.accountInputField.rx.text
            .map { Reactor.Action.inputAccountNumber($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editAccountView.bankInputField.rx.tap
            .map { Reactor.Action.didTapBank }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // TODO: didTapSave 바텀시트 연결 후 필요
        
        editAccountView.saveButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapSave }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Bind State
        reactor.state
            .map(\.bank?.description)
            .bind(to: editAccountView.bankInputField.rx.value)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.accountNumber)
            .bind(to: editAccountView.accountInputField.rx.value)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.isEnableSaveButton)
            .bind(to: editAccountView.rx.isEnableSaveButton)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .bind(onNext: { [weak self] route in
                self?.handleRoute(route)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleRoute(_ route: EditAccountReactor.Route) {
        switch route {
        case .pop:
            navigationController?.popViewController(animated: true)
            
        case .presentBankBottomSheet(let reactor):
            coordinator?.presentBankListBottomSheet(reactor: reactor)
        }
    }
}
