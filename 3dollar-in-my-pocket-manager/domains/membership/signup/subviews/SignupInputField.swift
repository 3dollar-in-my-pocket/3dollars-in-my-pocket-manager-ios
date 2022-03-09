import UIKit

import RxSwift
import RxCocoa

final class SignupInputField: BaseView {
    var maxLength: Int? {
        willSet(newValue) {
            self.textField.maxLength = newValue
        }
    }
    
    var keyboardType: UIKeyboardType? {
        willSet(newValue) {
            self.textField.keyboardType = newValue
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = .gray100
    }
    
    private let requiredDot = UIView().then {
        $0.backgroundColor = .pink
        $0.layer.cornerRadius = 2
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .pink
        $0.font = .bold(size: 12)
    }
    
    fileprivate let textField: SignupTextField
    
    init(
        title: String,
        isRequired: Bool = false,
        description: String? = nil,
        placeholder: String? = nil
    ) {
        self.textField = SignupTextField(placeholder: placeholder)
        super.init(frame: .zero)
        
        self.titleLabel.text = title
        self.requiredDot.isHidden = !isRequired
        self.descriptionLabel.text = description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.addSubViews([
            self.titleLabel,
            self.requiredDot,
            self.descriptionLabel,
            self.textField
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        self.requiredDot.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel)
            make.left.equalTo(self.titleLabel.snp.right).offset(4)
            make.width.height.equalTo(4)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.right.equalToSuperview()
        }
        
        self.textField.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.snp.makeConstraints { make in
            make.bottom.equalTo(self.textField).priority(.high)
        }
    }
}

extension Reactive where Base: SignupInputField {
    var text: ControlProperty<String> {
        return base.textField.rx.text
    }
}
