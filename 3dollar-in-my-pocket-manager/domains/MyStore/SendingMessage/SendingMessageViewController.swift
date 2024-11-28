import UIKit
import PanModal
import CombineCocoa

final class SendingMessageViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.text = Strings.SendingMessage.title
        label.numberOfLines = 0
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let image = Assets.icDeleteX.image.resizeImage(scaledTo: 30).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .gray40
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        
        let string = Strings.SendingMessage.description
        let coloredRange = (string as NSString).range(of: Strings.SendingMessage.Description.colored)
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray95, range: coloredRange)
        label.attributedText = attributedString
        return label
    }()
    
    private let textView = SendingMessageTextView()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .medium(size: 12)
        label.text = Strings.SendingMessage.warning
        return label
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.SendingMessage.send, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .semiBold(size: 14)
        return button
    }()
    
    private let viewModel: SendingMessageViewModel
    private var keyboardHeight: CGFloat = 0
    
    init(viewModel: SendingMessageViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
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
        textView.setText(viewModel.output.firstMessage)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubViews([
            titleLabel,
            closeButton,
            descriptionLabel,
            textView,
            warningLabel,
            sendButton
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(24)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
        }
        
        warningLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(textView.snp.bottom).offset(4)
        }
        
        sendButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
            $0.top.equalTo(warningLabel.snp.bottom).offset(28)
        }
    }
    
    private func bind() {
        closeButton.tapPublisher
            .withUnretained(self)
            .sink { (owner: SendingMessageViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        textView.textPublisher
            .compactMap { $0 }
            .subscribe(viewModel.input.inputText)
            .store(in: &cancellables)
        
        sendButton.tapPublisher
            .subscribe(viewModel.input.didTapSend)
            .store(in: &cancellables)
        
        viewModel.output.state
            .main
            .withUnretained(self)
            .sink { (owner: SendingMessageViewController, state: SendingMessageTextView.State) in
                owner.textView.setState(state)
                
                if state != .focused {
                    owner.warningLabel.textColor = state.textColor
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: SendingMessageViewController, route: SendingMessageViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
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
        self.keyboardHeight = inset
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
    
    @objc func onHideKeyboard(notification: Notification) {
        keyboardHeight = 0
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
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

extension SendingMessageViewController {
    private func handleRoute(_ route: SendingMessageViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        }
    }
}

extension SendingMessageViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(370 + keyboardHeight)
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
