import UIKit
import CombineCocoa

final class DeleteAccountViewController: BaseViewController {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 24, left: 20, bottom: 20, right: 24)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.text = Strings.DeleteAccount.title
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        label.text = Strings.DeleteAccount.description
        label.textAlignment = .center
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.DeleteAccount.delete, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold(size: 14)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.DeleteAccount.cancel, for: .normal)
        button.setTitleColor(.gray50, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold(size: 14)
        button.layer.borderColor = UIColor.gray50.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    let viewModel: DeleteAccountViewModel
    
    init(viewModel: DeleteAccountViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        view.addSubViews([
            containerView,
            stackView
        ])
        
        containerView.snp.makeConstraints {
            $0.edges.equalTo(stackView)
        }
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.setCustomSpacing(24, after: descriptionLabel)
        stackView.addArrangedSubview(deleteButton)
        stackView.setCustomSpacing(8, after: deleteButton)
        stackView.addArrangedSubview(cancelButton)
        
        deleteButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        cancelButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
    
    private func bind() {
        // Event
        cancelButton.tapPublisher
            .throttleClick()
            .withUnretained(self)
            .sink { (owner: DeleteAccountViewController, _) in
                owner.dismiss()
            }
            .store(in: &cancellables)
        
        // Input
        deleteButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapDelete)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: DeleteAccountViewController, error: any Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: DeleteAccountViewController, route: DeleteAccountViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { (message: String) in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
    }
    
    private func dismiss() {
        DimManager.shared.hideDim()
        dismiss(animated: true)
    }
}

extension DeleteAccountViewController {
    private func handleRoute(_ route: DeleteAccountViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss()
        }
    }
}
