import UIKit

final class CouponRegisterView: BaseView {
    let tapBackground = UITapGestureRecognizer()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 16)
        label.textColor = .gray100
        label.text = "쿠폰 만들기"
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    let couponTitleField = CouponNameInputField(
        title: "쿠폰명",
        description: "혜택이 바로 보이도록 40자 이내로 입력해주세요.",
        placeholder: "예) 1000원 할인, 5천원 이상 구매시 500원 할인!"
    ).then {
        $0.maxLength = 40
    }
    
    let dateInputView = CouponDateInputView()
    let countInputView = CouponCountInputView()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("쿠폰 발급하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .semiBold(size: 14)
        button.backgroundColor = .gray20
        button.layer.cornerRadius = 12
        button.isEnabled = false
        return button
    }()
    
    private var originalBottomInset: CGFloat = 0
    private var isKeyboardShown = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        setupKeyboardEvent()
        setupLayout()
        bindEvent()
    }
    
    private func bindEvent() {
        tapBackground.addTarget(self, action: #selector(didTapBackground))
        tapBackground.cancelsTouchesInView = false
    }
    
    private func setupLayout() {
        backgroundColor = .gray0
        addGestureRecognizer(tapBackground)
        
        addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(15)
            $0.size.equalTo(24)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        stackView.addArrangedSubview(couponTitleField)
        stackView.setCustomSpacing(42, after: couponTitleField)
        stackView.addArrangedSubview(dateInputView)
        stackView.setCustomSpacing(24, after: dateInputView)
        stackView.addArrangedSubview(countInputView)
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
            $0.top.equalToSuperview().offset(14)
            $0.bottom.equalToSuperview().offset(-44)
        }
        
        addSubview(registerButton)
        registerButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(48)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(21)
            $0.width.equalTo(UIUtils.windowBounds.width).priority(.high)
            $0.bottom.equalTo(registerButton.snp.top)
        }
    }
    
    func bind() {
        
    }
    
    func setRegisterButtonEnable(_ isEnable: Bool) {
        registerButton.isEnabled = isEnable
        registerButton.backgroundColor = isEnable ? .green : .gray20
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
        guard isKeyboardShown.isNot else { return }
        let keyboardHeight = mapNotificationToKeyboardHeight(notification: notification)
        let inset = keyboardHeight > 0 ? (keyboardHeight - safeAreaInsets.bottom) : 0
        originalBottomInset = scrollView.contentInset.bottom
        scrollView.contentInset.bottom += inset
        isKeyboardShown = true
    }
    
    @objc func onHideKeyboard(notification: Notification) {
        scrollView.contentInset.bottom = originalBottomInset
        isKeyboardShown = false
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
    
    @objc func didTapBackground() {
        endEditing(true)
    }
}
