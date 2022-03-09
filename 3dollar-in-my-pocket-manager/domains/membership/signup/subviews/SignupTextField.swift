import UIKit

class SignupTextField: BaseView {
    private let containerView = UIView().then {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 8
    }
    
    fileprivate let textField = UITextField().then {
        $0.font = .medium(size: 14)
        $0.textColor = .gray30
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.textField
        ])
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
    
    fileprivate func setFocusMode(isFocus: Bool) {
        
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
