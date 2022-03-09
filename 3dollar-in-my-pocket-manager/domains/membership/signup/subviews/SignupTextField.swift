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
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 8
    }
    
    fileprivate let textField = UITextField().then {
        $0.font = .medium(size: 14)
        $0.textColor = .gray30
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
        
        self.textField.rx.controlEvent(.editingDidBegin)
            .map { _ in true }
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] isFocus in
                self?.setFocusMode(isFocus: isFocus)
            })
            .disposed(by: self.disposeBag)
        
        self.textField.rx.controlEvent(.editingDidEnd)
            .map { _ in false }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isFocus in
                self?.setFocusMode(isFocus: isFocus)
            })
            .disposed(by: self.disposeBag)
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
    
    private func setFocusMode(isFocus: Bool) {
        UIView.transition(
            with: self,
            duration: 0.3,
            options: .curveEaseInOut
        ) { [weak self] in
            self?.containerView.backgroundColor = isFocus ? .white : .gray5
            self?.textField.textColor = isFocus ? .gray100 : .gray30
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

extension SignupTextField: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text,
              let maxLength = self.maxLength else { return true }
        let newLength = text.count + string.count - range.length
        
        return newLength <= maxLength
    }
}

extension Reactive where Base: SignupTextField {
    var text: ControlProperty<String> {
        return base.textField.rx.text.orEmpty
    }
}
