import UIKit
import Combine
import CombineCocoa

final class SendingMessageTextView: BaseView {
    enum Layout {
        static let height: CGFloat = 128
    }
    
    enum State {
        case warning
        case focused
        case normal
        
        var borderColor: CGColor? {
            switch self {
            case .normal:
                return nil
            case .focused:
                return UIColor.green.cgColor
            case .warning:
                return UIColor.red.cgColor
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .normal:
                return .gray80
            case .focused:
                return .green
            case .warning:
                return .red
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .warning:
                return 1
            case .focused:
                return 1
            case .normal:
                return 0
            }
        }
    }
    
    private let textView: UITextView = {
        let textView =  UITextView()
        textView.font = .regular(size: 14)
        textView.textColor = .gray40
        textView.textAlignment = .left
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let currentCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .medium(size: 12)
        label.text = "0"
        return label
    }()
    
    private let limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .medium(size: 12)
        label.text = "/100"
        return label
    }()
    
    var textPublisher: AnyPublisher<String?, Never> {
        return textView.textPublisher
    }
    
    override func setup() {
        setupUI()
        bind()
        textView.delegate = self
    }
    
    func setState(_ state: State) {
        layer.borderColor = state.borderColor
        layer.borderWidth = state.borderWidth
        currentCountLabel.textColor = state.textColor
    }
    
    func setText(_ text: String) {
        textView.text = text
    }
    
    private func setupUI() {
        backgroundColor = .gray10
        layer.cornerRadius = 12
        layer.masksToBounds = true
        addSubViews([
            textView,
            currentCountLabel,
            limitLabel
        ])
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(limitLabel.snp.top).offset(-8)
        }
        
        currentCountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        limitLabel.snp.makeConstraints {
            $0.leading.equalTo(currentCountLabel.snp.trailing)
            $0.centerY.equalTo(currentCountLabel)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
    
    private func bind() {
        textView.textPublisher
            .withUnretained(self)
            .sink { (owner: SendingMessageTextView, text: String?) in
                let length = text?.count ?? 0
                
                owner.currentCountLabel.text = "\(length)"
            }
            .store(in: &cancellables)
    }
}

extension SendingMessageTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        setState(.focused)
        textView.textColor = .gray95
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
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
        
        return count <= SendingMessageViewModel.Constant.maximumLength
    }
}
