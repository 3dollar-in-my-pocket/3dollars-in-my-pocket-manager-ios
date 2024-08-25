import UIKit

final class EditAccountViewController: BaseViewController {
    private let viewModel: EditAccountViewModel
    private let editAccountView = EditAccountView()
    
    init(viewModel: EditAccountViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
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
        
        bind()
    }
    
    private func bind() {
        // Event
        editAccountView.backButton.tapPublisher
            .throttleClick()
            .main
            .withUnretained(self)
            .sink { (owner: EditAccountViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        // Input
        editAccountView.nameInputField.textField.textPublisher
            .dropFirst()
            .compactMap { $0 }
            .subscribe(viewModel.input.inputName)
            .store(in: &cancellables)
        
        editAccountView.accountInputField.textField.textPublisher
            .dropFirst()
            .compactMap { $0 }
            .subscribe(viewModel.input.inputAccountNumber)
            .store(in: &cancellables)
        
        editAccountView.bankInputField.arrowDownButton.tapPublisher
            .mapVoid
            .subscribe(viewModel.input.didTapBank)
            .store(in: &cancellables)
        
        editAccountView.saveButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.store
            .main
            .withUnretained(self)
            .sink { (owner: EditAccountViewController, store: BossStoreResponse) in
                owner.editAccountView.bind(store: store)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableSaveButton
            .main
            .withUnretained(self)
            .sink { (owner: EditAccountViewController, isEnable: Bool) in
                owner.editAccountView.setSaveButtonEnable(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { (isShow: Bool) in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { (message: String) in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: EditAccountViewController, route: EditAccountViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
}

// MARK: Route
extension EditAccountViewController {
    private func handleRoute(_ route: EditAccountViewModel.Route) {
        switch route {
        case .pop:
            navigationController?.popViewController(animated: true)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .presentBankBottomSheet(let viewModel):
            presentBankBotomSheet(viewModel: viewModel)
        }
    }
    
    private func presentBankBotomSheet(viewModel: BankListBottomSheetViewModel) {
        let viewController = BankListBottomSheetViewController(viewModel: viewModel)
        
        presentPanModal(viewController)
    }
}
