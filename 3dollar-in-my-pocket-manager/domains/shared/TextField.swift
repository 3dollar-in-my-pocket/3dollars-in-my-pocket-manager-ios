import UIKit

import RxSwift
import RxCocoa

final class TextField: BaseView {
    var maxLength: Int?
    
    var keyboardType: UIKeyboardType? {
        didSet(newValue) {
            guard let keyboardType = keyboardType else { return }
            
            self.textField.keyboardType = keyboardType
        }
    }
    
    var format: String?
    
    fileprivate lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 8
        return view
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.font = .medium(size: 14)
        textField.textColor = .gray100
        return textField
    }()
    
    init(placeholder: String? = nil) {
        super.init(frame: .zero)
        
        self.setPlaceholder(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        setupLayout()
        textField.delegate = self
    }
    
    func setText(text: String?) {
        self.textField.text = text
    }
    
    func setDate(date: Date) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"
        datePicker.date = date
        textField.text = dateFormatter.string(from: date)
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
    
    private func setupLayout() {
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        addSubview(textField)
        textField.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(12)
            $0.right.equalTo(containerView).offset(-12)
            $0.centerY.equalTo(containerView)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
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
        return base.datePicker.rx.date.changed
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
