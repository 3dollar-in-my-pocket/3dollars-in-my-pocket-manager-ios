import UIKit

final class EditAccountViewController: BaseViewController {
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icBack.image, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 16)
        label.textColor = .gray100
        label.text = Strings.EditAccount.accountNumber
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 32, left: 24, bottom: 32, right: 24)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let accountInputField = EditAccountInputField(
        title: Strings.EditAccount.accountNumber,
        isRedDotHidden: false,
        isRightButtonHidden: true,
        placeholder: Strings.EditAccount.accountNumberPlaceholder
    )
    
    private let bankInputField: EditAccountInputField = {
        let inputField = EditAccountInputField(
            title: Strings.EditAccount.bank,
            isRedDotHidden: false,
            isRightButtonHidden: false,
            placeholder: Strings.EditAccount.bankPlaceholder
        )
        inputField.textField.isUserInteractionEnabled = false
        return inputField
    }()
    
    private let nameInputField = EditAccountInputField(
        title: Strings.EditAccount.name,
        isRedDotHidden: false,
        isRightButtonHidden: true,
        placeholder: Strings.EditAccount.titlePlaceholder
    )
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.EditAccount.deleteAccountNumber, for: .normal)
        button.titleLabel?.font = .regular(size: 14)
        button.setTitleColor(.gray50, for: .normal)
        button.setImage(Assets.icTrash.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .gray50
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.EditAccount.save, for: .normal)
        button.titleLabel?.font = .medium(size: 16)
        button.setTitleColor(.white, for: .normal)
        button.imageEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
        return button
    }()
    
    fileprivate let buttonBackgroundView = UIView()
    private var originalBottomInset: CGFloat = 0
    
    private let viewModel: EditAccountViewModel
    
    init(viewModel: EditAccountViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupKeyboardEvent()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubViews([
            backButton,
            titleLabel,
            scrollView,
            saveButton,
            buttonBackgroundView
        ])
        
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(accountInputField)
        stackView.setCustomSpacing(32, after: accountInputField)
        stackView.addArrangedSubview(bankInputField)
        stackView.setCustomSpacing(32, after: bankInputField)
        stackView.addArrangedSubview(nameInputField)
        stackView.setCustomSpacing(24, after: nameInputField)
        
        if viewModel.output.store.value.accountNumbers.isNotEmpty {
            stackView.addArrangedSubview(horizontalStackView)
            horizontalStackView.addArrangedSubview(UIView())
            horizontalStackView.addArrangedSubview(deleteButton)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(21)
            $0.bottom.equalTo(saveButton.snp.top)
        }
        
        
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func bind() {
        // Event
        backButton.tapPublisher
            .throttleClick()
            .main
            .withUnretained(self)
            .sink { (owner: EditAccountViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        // Input
        nameInputField.textField.textPublisher
            .dropFirst()
            .compactMap { $0 }
            .subscribe(viewModel.input.inputName)
            .store(in: &cancellables)
        
        accountInputField.textField.textPublisher
            .dropFirst()
            .compactMap { $0 }
            .subscribe(viewModel.input.inputAccountNumber)
            .store(in: &cancellables)
        
        bankInputField.arrowDownButton.tapPublisher
            .mapVoid
            .subscribe(viewModel.input.didTapBank)
            .store(in: &cancellables)
        
        saveButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)
        
        deleteButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapDeleteAccountNumber)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.store
            .compactMap { $0.accountNumbers.first }
            .main
            .withUnretained(self)
            .sink { (owner: EditAccountViewController, account: BossStoreAccountNumber) in
                owner.setAccount(account)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableSaveButton
            .main
            .withUnretained(self)
            .sink { (owner: EditAccountViewController, isEnable: Bool) in
                owner.setSaveButtonEnable(isEnable)
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
    
    private func setAccount(_ account: BossStoreAccountNumber) {
        nameInputField.textField.text = account.accountHolder
        accountInputField.textField.text = account.accountNumber
        bankInputField.textField.text = account.bank.description
    }
    
    private func setSaveButtonEnable(_ isEnable: Bool) {
        if isEnable {
            saveButton.backgroundColor = .green
            buttonBackgroundView.backgroundColor = .green
        } else {
            saveButton.backgroundColor = .gray30
            buttonBackgroundView.backgroundColor = .gray30
        }
    }
    
    private func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onShowKeyboard(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onHideKeyboard(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func onShowKeyboard(notification: Notification) {
        let keyboardHeight = mapNotificationToKeyboardHeight(notification: notification)
        let inset = keyboardHeight > 0 ? (keyboardHeight - view.safeAreaInsets.bottom) : 0
        originalBottomInset = scrollView.contentInset.bottom
        scrollView.contentInset.bottom += inset
    }
    
    @objc func onHideKeyboard(notification: Notification) {
        scrollView.contentInset.bottom = originalBottomInset
    }
    
    private func mapNotificationToKeyboardHeight(notification: Notification) -> CGFloat {
        if notification.name == UIResponder.keyboardDidShowNotification ||
            notification.name == UIResponder.keyboardWillShowNotification {
            let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            return rect.height
        } else {
            return 0
        }
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
        case .presentDeleteAccountNumberDialog(let viewModel):
            presentDeleteAccountNumberDialog(viewModel: viewModel)
        }
    }
    
    private func presentBankBotomSheet(viewModel: BankListBottomSheetViewModel) {
        let viewController = BankListBottomSheetViewController(viewModel: viewModel)
        
        presentPanModal(viewController)
    }
    
    private func presentDeleteAccountNumberDialog(viewModel: DeleteAccountViewModel) {
        let viewController = DeleteAccountViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
}
