import UIKit
import Combine
import SnapKit

final class CouponCountInputView: UIView {
    enum Option: Equatable {
        case unlimited
        case fixed(Int)
        case custom(Int?)
        
        var value: Int? {
            switch self {
            case .unlimited: return 999
            case .fixed(let value): return value
            case .custom(let value): return value
            }
        }
    }

    let updateValue = PassthroughSubject<Int?, Never>()

    func configure(option: Option) {
        switch option {
        case .unlimited:
            select(button: unlimitedButton)
            hideTextField()
        case .fixed(let n):
            if n == 10 { select(button: tenButton) }
            else if n == 30 { select(button: thirtyButton) }
            else { select(button: customButton) }
            hideTextField()
        case .custom(let n):
            select(button: customButton)
            showTextField()
            if let n { inputField.text = String(n) } else { inputField.text = nil }
        }
        emit()
    }

    private(set) var selected: Option = .unlimited

    // MARK: UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "발급 수량"
        l.font = .bold(size: 16)
        l.textColor = .gray95
        return l
    }()

    private let descLabel: UILabel = {
        let l = UILabel()
        l.text = "쿠폰 사용 기간 동안 발급받을 수 있는 쿠폰의 수량을 선택해주세요.\n종료일 전에 쿠폰 수량 소진 시"
        l.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        l.attributedText = NSAttributedString(
            string: l.text ?? "",
            attributes: [.font: UIFont.medium(size: 12) ?? .systemFont(ofSize: 12), .foregroundColor: UIColor.gray50, .paragraphStyle: style]
        )
        return l
    }()

    private lazy var unlimitedButton = makeOptionButton(title: "무제한")
    private lazy var tenButton       = makeOptionButton(title: "10개")
    private lazy var thirtyButton    = makeOptionButton(title: "30개")
    private lazy var customButton    = makeOptionButton(title: "수량 입력")

    private let buttonsContainer = UIStackView()

    private let inputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.gray5
        v.layer.cornerRadius = 8
        return v
    }()

    private let inputField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.placeholder = "수량을 입력해주세요."
        tf.font = .regular(size: 14)
        tf.textColor = .gray40
        return tf
    }()

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
}

// MARK: - Setup
private extension CouponCountInputView {
    func setup() {
        backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(buttonsContainer)
        addSubview(inputContainer)
        inputContainer.addSubview(inputField)

        // layout
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        buttonsContainer.axis = .horizontal
        buttonsContainer.alignment = .fill
        buttonsContainer.distribution = .fillEqually
        buttonsContainer.spacing = 8
        buttonsContainer.addArrangedSubview(unlimitedButton)
        buttonsContainer.addArrangedSubview(tenButton)
        buttonsContainer.addArrangedSubview(thirtyButton)
        buttonsContainer.addArrangedSubview(customButton)

        buttonsContainer.snp.makeConstraints {
            $0.top.equalTo(descLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(38)
        }

        inputContainer.snp.makeConstraints {
            $0.top.equalTo(buttonsContainer.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }

        inputField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        // actions
        unlimitedButton.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
        tenButton.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
        thirtyButton.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
        customButton.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
        inputField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        // number-only filtering
        inputField.delegate = self
        addDoneAccessory()

        configure(option: .unlimited)
    }

    func makeOptionButton(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .medium(size: 12)
        b.setTitleColor(.gray50, for: .normal)
        b.backgroundColor = .gray5
        b.layer.cornerRadius = 8
        b.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return b
    }

    func select(button: UIButton) {
        [unlimitedButton, tenButton, thirtyButton, customButton].forEach { b in
            b.backgroundColor = .gray5
            b.setTitleColor(.gray50, for: .normal)
            b.titleLabel?.font = .medium(size: 12)
        }
        button.backgroundColor = .green
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .bold(size: 12)

        if button === unlimitedButton { selected = .unlimited }
        else if button === tenButton { selected = .fixed(10) }
        else if button === thirtyButton { selected = .fixed(30) }
        else { selected = .custom(currentCustomNumber()) }
    }

    func showTextField() {
        inputContainer.isHidden = false
        inputContainer.alpha = 1
        inputField.isEnabled = true
    }

    func hideTextField() {
        inputContainer.isHidden = true
        inputField.isEnabled = false
        inputField.text = inputField.text
    }

    func emit() {
        updateValue.send(selected.value)
    }

    func addDoneAccessory() {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 38))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneEditing))
        done.tintColor = .gray10
        bar.items = [flex, done]
        inputField.inputAccessoryView = bar
    }
}

// MARK: - Actions
private extension CouponCountInputView {
    @objc func tapOption(_ sender: UIButton) {
        select(button: sender)
        if sender === customButton { showTextField(); inputField.becomeFirstResponder() }
        else { hideTextField(); endEditing(true) }
        emit()
    }

    @objc func textChanged() {
        // update option with current text
        if case .custom = selected {
            selected = .custom(currentCustomNumber())
            emit()
        }
    }

    @objc func doneEditing() { endEditing(true) }

    func currentCustomNumber() -> Int? {
        guard let t = inputField.text, let n = Int(t), n >= 0 else { return nil }
        return n
    }
}

// MARK: - UITextFieldDelegate
extension CouponCountInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true } // backspace
        // only digits
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
    }
}
