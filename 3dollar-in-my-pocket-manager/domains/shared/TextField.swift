import UIKit

import RxSwift
import RxCocoa
import Base

final class TextField: BaseView {
    var maxLength: Int?
    
    var keyboardType: UIKeyboardType? {
        didSet(newValue) {
            guard let keyboardType = keyboardType else { return }
            
            self.textField.keyboardType = keyboardType
        }
    }
    
    var format: String?
    
    fileprivate lazy var datePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 8
    }
    
    fileprivate let textField = UITextField().then {
        $0.font = .medium(size: 14)
        $0.textColor = .gray100
    }
    
    init(placeholder: String? = nil) {
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
    
    func setText(text: String?) {
        self.textField.text = text
    }
    
    func setDate(date: Date) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"
        self.datePicker.date = date
        self.textField.text = dateFormatter.string(from: date)
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

extension TextField: UITextFieldDelegate {
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

extension Reactive where Base: TextField {
    var text: ControlProperty<String> {
        return base.textField.rx.text.orEmpty
    }
    
    var date: Observable<String> {
        return base.datePicker.rx.date
            .map { date -> String in
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateFormat = "HH:mm"
                return dateFormatter.string(from: date)
            }
    }
}

extension TextField {
    func setDatePicker() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem().then {
            $0.title = "완료"
        }
        doneButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.endEditing(true)
            })
            .disposed(by: self.disposeBag)
        
        toolbar.sizeToFit()
        toolbar.setItems([doneButton], animated: true)
        self.textField.inputAccessoryView = toolbar
        self.textField.inputView = self.datePicker
        self.datePicker.rx.value
            .asDriver()
            .skip(1)
            .drive(onNext: { [weak self] date in
                self?.setDate(date: date)
            })
            .disposed(by: self.disposeBag)
    }
}
