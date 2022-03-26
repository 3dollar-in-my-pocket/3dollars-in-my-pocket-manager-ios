import UIKit

import RxSwift
import RxCocoa

final class SignupTextField: BaseView {
    var maxLength: Int?
    
    var keyboardType: UIKeyboardType? {
        didSet(newValue) {
            guard let keyboardType = keyboardType else { return }
            
            self.textField.keyboardType = keyboardType
        }
    }
    
    var format: String?
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 8
    }
    
    fileprivate let textField = UITextField().then {
        $0.font = .medium(size: 14)
        $0.textColor = .gray100
    }
    
    init(placeholder: String?) {
        super.init(frame: .zero)
        
        self.setPlaceholder(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.textField
        ])
        self.textField.delegate = self
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(48)
        }
        
        self.textField.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
            make.centerY.equalTo(self.containerView)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView)
        }
    }
    
    fileprivate func format(with mask: String, text: String) -> String {
        let numbers = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    private func setPlaceholder(placeholder: String?) {
        guard let placeholder = placeholder else { return }
        let attributedString = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.gray30]
        )
        
        self.textField.attributedPlaceholder = attributedString
    }
}

extension SignupTextField: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if let format = self.format {
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            
            textField.text = self.format(with: format, text: newString)
            return false
        } else {
            guard let text = textField.text,
                  let maxLength = self.maxLength else { return true }
            let newLength = text.count + string.count - range.length
            
            return newLength <= maxLength
        }
    }
}

extension Reactive where Base: SignupTextField {
    var text: ControlProperty<String> {
        return base.textField.rx.text.orEmpty
    }
}
