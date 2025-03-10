import UIKit

import PanModal
import CombineCocoa

final class ReviewReportBottomSheet: BaseViewController {
    enum Constants {
        static let placeHolder: String = Strings.ReviewReportBottomSheet.placeholder
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray100
        label.font = .semiBold(size: 20)
        label.text = Strings.ReviewReportBottomSheet.title
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icDeleteX.image, for: .normal)
        return button
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        label.text = Strings.ReviewReportBottomSheet.subtitle
        return label
    }()
    
    private let textViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .regular(size: 14)
        textView.textColor = .gray40
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.text = Constants.placeHolder
        return textView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .medium(size: 12)
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ReviewReportBottomSheet.info
        label.font = .medium(size: 12)
        label.textColor = .gray50
        return label
    }()
    
    private let reportButton: UIButton = {
        let button = UIButton()
        button.setBackgroundColor(color: .gray30, forState: .disabled)
        button.setBackgroundColor(color: .red, forState: .normal)
        button.setTitle(Strings.ReviewReportBottomSheet.report, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .semiBold(size: 14)
        return button
    }()
    
    private let viewModel: ReviewReportBottomSheetViewModel
    private let tapGesture = UITapGestureRecognizer()
    private var keyboardInset: CGFloat = 0
    
    init(viewModel: ReviewReportBottomSheetViewModel) {
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
        setupAttributes()
        setupKeyboardEvent()
        bind()
    }
    
    private func setupAttributes() {
        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTapBackground))
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(subTitleLabel)
        view.addSubview(textViewContainer)
        textViewContainer.addSubview(textView)
        textViewContainer.addSubview(countLabel)
        view.addSubview(infoLabel)
        view.addSubview(reportButton)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-16)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        textViewContainer.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(16)
            $0.height.equalTo(300)
        }
        
        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-36)
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        infoLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(textViewContainer.snp.bottom).offset(4)
        }
        
        reportButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(infoLabel.snp.bottom).offset(28)
            $0.height.equalTo(48)
        }
    }
    
    private func bind() {
        // Input
        closeButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: ReviewReportBottomSheet, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        reportButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapReport)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.isEnableReportButton
            .main
            .withUnretained(self)
            .sink { (owner: ReviewReportBottomSheet, isEnable: Bool) in
                owner.reportButton.isEnabled = isEnable
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: ReviewReportBottomSheet, route: ReviewReportBottomSheetViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func setupTextCount(count: Int) {
        let string = "\(count)/\(ReviewReportBottomSheetViewModel.Constants.maxLength)"
        let attributedString = NSMutableAttributedString(string: string)
        let boldRange = NSString(string: string).range(of: "\(count)")
        
        attributedString.addAttribute(.font, value: UIFont.semiBold(size: 12) as Any, range: boldRange)
        countLabel.attributedText = attributedString
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
    
    @objc private func didTapBackground() {
        view.endEditing(true)
    }
}

// MARK: Route
extension ReviewReportBottomSheet {
    private func handleRoute(_ route: ReviewReportBottomSheetViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}

extension ReviewReportBottomSheet: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(516 + keyboardInset)
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
}

extension ReviewReportBottomSheet: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .gray95
        
        if textView.text == Constants.placeHolder {
            textView.text = nil
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.input.inputText.send(textView.text)
        
        if textView.text != Constants.placeHolder {
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
        
        return count <= ReviewReportBottomSheetViewModel.Constants.maxLength
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = UIColor.clear.cgColor

        if textView.text.isEmpty {
            textView.text = Constants.placeHolder
            textView.textColor = .gray40
        }

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.placeHolder
            textView.textColor = .gray40
        }
    }
}
