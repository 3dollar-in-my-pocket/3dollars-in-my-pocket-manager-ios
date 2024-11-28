import UIKit
import CombineCocoa

final class ConfirmMessageViewController: BaseViewController {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.numberOfLines = 0
        
        let text = Strings.MessageConfirm.title
        let style = NSMutableParagraphStyle()
        
        style.maximumLineHeight = 28
        style.minimumLineHeight = 28
        style.alignment = .center
        label.attributedText = NSMutableAttributedString(string: text, attributes: [.paragraphStyle: style,])
        return label
    }()
    
    private let messageContentView = ConfirmMessageContentView()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.MessageConfirm.send, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold(size: 14)
        return button
    }()
    
    private let rewriteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.MessageConfirm.rewrite, for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.titleLabel?.font = .bold(size: 14)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.green.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let viewModel: ConfirmMessageViewModel
    
    init(viewModel: ConfirmMessageViewModel) {
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
        viewModel.input.firstLoad.send(())
        messageContentView.bind(storeName: viewModel.output.storeName, message: viewModel.output.message)
    }
    
    private func setupUI() {
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        view.addSubViews([
            containerView,
            stackView
        ])
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.addArrangedSubview(messageContentView)
        stackView.setCustomSpacing(24, after: messageContentView)
        stackView.addArrangedSubview(sendButton)
        stackView.setCustomSpacing(8, after: sendButton)
        stackView.addArrangedSubview(rewriteButton)
        
        sendButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        rewriteButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(containerView).offset(20)
            $0.trailing.equalTo(containerView).offset(-20)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(stackView).offset(-24)
            $0.bottom.equalTo(stackView).offset(24)
        }
    }
    
    private func bind() {
        sendButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSend)
            .store(in: &cancellables)
        
        rewriteButton.tapPublisher
            .subscribe(viewModel.input.didTapReWrite)
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: ConfirmMessageViewController, route: ConfirmMessageViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: ConfirmMessageViewController, error: any Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { (message: String) in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
    }
}


// MARK: Route
extension ConfirmMessageViewController {
    private func handleRoute(_ route: ConfirmMessageViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true) {
                DimManager.shared.hideDim()
            }
        }
    }
}
