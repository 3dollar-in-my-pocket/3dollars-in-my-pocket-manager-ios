import UIKit
import Combine

final class ReviewDetailCommentInputView: BaseView {
    enum Layout {
        static let height: CGFloat = 521
    }
    
    enum Constant {
        static let maxInputLength = 300
        static let placeHolder = "소중한 리뷰 감사드립니다!"
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 0, left: 24, bottom: 50, right: 24)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray20
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.text = "리뷰에 답글을 달아주세요!"
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        label.text = "부적절한 내용의 답글일 경우 삭제될 수 있습니다."
        return label
    }()
    
    private let textViewContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .gray5
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .regular(size: 14)
        textView.textColor = .gray40
        textView.backgroundColor = .clear
        textView.text = Constant.placeHolder
        textView.delegate = self
        return textView
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray50
        return label
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray50
        label.text = "*최소 10자에서 최대 300자 이내로 입력해 주세요."
        return label
    }()
    
    private let macroButton: UIButton = {
        let button = UIButton()
        button.setTitle("자주 쓰는 문구", for: .normal)
        button.backgroundColor = .gray5
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold(size: 12)
        button.setTitleColor(.gray90, for: .normal)
        return button
    }()
    
    let textPublisher = PassthroughSubject<String, Never>()
    private var isFocusedState = false
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(dividerView)
        dividerView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        stackView.setCustomSpacing(22, after: dividerView)
        
        stackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        stackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        stackView.setCustomSpacing(16, after: descriptionLabel)
        
        setupTextView()
        
        stackView.addArrangedSubview(warningLabel)
        warningLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        stackView.setCustomSpacing(20, after: warningLabel)
        
        stackView.addArrangedSubview(macroButton)
        macroButton.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
    }
    
    private func setupTextView() {
        stackView.addArrangedSubview(textViewContainer)
        stackView.setCustomSpacing(4, after: textViewContainer)
        textViewContainer.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
        textViewContainer.addSubview(textView)
        textViewContainer.addSubview(textCountLabel)
        
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-36)
        }
        
        textCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        setupTextCount(count: 0)
    }
    
    private func setTextViewFocus(isFocused: Bool) {
        let borderColor: UIColor = isFocused ? .green : .clear
        textViewContainer.layer.borderColor = borderColor.cgColor
        isFocusedState = isFocused
    }
    
    private func setupTextCount(count: Int) {
        let textColor: UIColor = count == 0 ?  .gray80 : .green
        let text = "\(count)/\(Constant.maxInputLength)"
        let coloredRange = (text as NSString).range(of: "\(count)")
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: textColor, range: coloredRange)
        textCountLabel.attributedText = attributedString
    }
}

extension ReviewDetailCommentInputView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        setTextViewFocus(isFocused: true)
        textView.textColor = .gray95
        
        if textView.text == Constant.placeHolder {
            textView.text = nil
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textPublisher.send(textView.text)
        
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
        setTextViewFocus(isFocused: false)
        textView.layer.borderColor = UIColor.clear.cgColor

        if textView.text.isEmpty {
            textView.text = Constant.placeHolder
            textView.textColor = .gray40
        }
    }
}
