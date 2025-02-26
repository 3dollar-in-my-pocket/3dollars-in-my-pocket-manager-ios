import UIKit

import PanModal

final class AddCommentPresetBottomSheet: BaseViewController {
    enum Constant {
        static let placeHolder = Strings.AddCommentPresetBottomSheet.placeholder
        static let maxInputLength = 300
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray100
        label.font = .semiBold(size: 20)
        label.text = Strings.AddCommentPresetBottomSheet.title
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icDeleteX.image, for: .normal)
        return button
    }()
    
    private let textContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .gray5
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = Constant.placeHolder
        textView.font = .regular(size: 14)
        textView.textColor = .gray95
        textView.backgroundColor = .clear
        textView.delegate = self
        return textView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .medium(size: 12)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray30
        button.setTitle(Strings.AddCommentPresetBottomSheet.add, for: .normal)
        button.titleLabel?.font = .semiBold(size: 14)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let buttonBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .gray30
        return view
    }()
    
    private let viewModel: AddCommentPresetBottomSheetViewModel
    private var keyboardInset: CGFloat = 0
    
    init(viewModel: AddCommentPresetBottomSheetViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupKeyboardEvent()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
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
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(textContainerView)
        textContainerView.addSubview(textView)
        textContainerView.addSubview(countLabel)
        view.addSubview(addButton)
        view.addSubview(buttonBackground)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-16)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(30)
            $0.centerY.equalTo(titleLabel)
        }
        
        textContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.height.equalTo(300)
        }
        
        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(254)
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        addButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(textContainerView.snp.bottom).offset(20)
            $0.height.equalTo(48)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(addButton.snp.bottom)
        }
    }
    
    private func bind() {
        // Input
        addButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapAdd)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.isEnableAddButton
            .main
            .withUnretained(self)
            .sink { (owner: AddCommentPresetBottomSheet, isEnable: Bool) in
                owner.setAddButtonEnable(isEnable: isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: AddCommentPresetBottomSheet, route: AddCommentPresetBottomSheetViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    @objc func onShowKeyboard(notification: Notification) {
        let keyboardHeight = mapNotificationToKeyboardHeight(notification: notification)
        let inset = keyboardHeight > 0 ? (keyboardHeight - view.safeAreaInsets.bottom) : 0
        keyboardInset = inset
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
    
    @objc func onHideKeyboard(notification: Notification) {
        keyboardInset = 0
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
    
    private func setupTextCount(count: Int) {
        let textColor: UIColor = count == 0 ?  .gray50 : .green
        let text = "\(count)/\(Constant.maxInputLength)"
        let coloredRange = (text as NSString).range(of: "\(count)")
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: textColor, range: coloredRange)
        countLabel.attributedText = attributedString
    }
    
    private func setAddButtonEnable(isEnable: Bool) {
        let backgroundColor: UIColor = isEnable ? .green : .gray30
        addButton.isEnabled = isEnable
        addButton.backgroundColor = backgroundColor
        buttonBackground.backgroundColor = backgroundColor
    }
}

extension AddCommentPresetBottomSheet: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .gray95
        
        if textView.text == Constant.placeHolder {
            textView.text = nil
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.input.inputText.send(textView.text)
        
        if textView.text != Constant.placeHolder {
            setupTextCount(count: textView.text.count)
        }
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let textFieldText = textView.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
          return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + text.count
        
        return count <= Constant.maxInputLength
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = UIColor.clear.cgColor

        if textView.text.isEmpty {
            textView.text = Constant.placeHolder
            textView.textColor = .gray40
        }

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constant.placeHolder
            textView.textColor = .gray40
        }
    }
}

// MARK: Route
extension AddCommentPresetBottomSheet {
    private func handleRoute(_ route: AddCommentPresetBottomSheetViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}

extension AddCommentPresetBottomSheet: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(438 + keyboardInset)
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
