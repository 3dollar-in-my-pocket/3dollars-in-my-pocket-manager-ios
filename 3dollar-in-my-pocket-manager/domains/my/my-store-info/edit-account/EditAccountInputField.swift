import UIKit

import RxSwift
import RxCocoa

final class EditAccountInputField: BaseView {
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = .gray100
    }
    
    private let redDot = UIView().then {
        $0.backgroundColor = .pink
        $0.layer.cornerRadius = 2
        $0.isHidden = true
    }
    
    private let textFieldContainer = UIView().then {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 8
    }
    
    let textField = UITextField().then {
        $0.textColor = .gray100
        $0.font = .medium(size: 14)
    }
    
    fileprivate let arrowDownButton = UIButton().then {
        let icon = UIImage(named: "ic_arrow_down")?
            .withRenderingMode(.alwaysTemplate)
        
        $0.setImage(icon, for: .normal)
        $0.tintColor = .gray50
        $0.isHidden = true
    }
    
    private let isRightButtonHidden: Bool
    
    init(
        title: String,
        isRedDotHidden: Bool,
        isRightButtonHidden: Bool,
        placeholder: String? = nil
    ) {
        self.isRightButtonHidden = isRightButtonHidden
        redDot.isHidden = isRedDotHidden
        arrowDownButton.isHidden = isRightButtonHidden
        titleLabel.text = title
        
        super.init(frame: .zero)
        
        setPlaceholder(placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        addSubViews([
            titleLabel,
            redDot,
            textFieldContainer,
            textField,
            arrowDownButton
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        redDot.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.size.equalTo(4)
        }
        
        textFieldContainer.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalTo(textFieldContainer).offset(12)
            
            if isRightButtonHidden {
                $0.trailing.equalTo(textFieldContainer).offset(-12)
            } else {
                $0.trailing.equalTo(arrowDownButton.snp.leading).offset(-8)
            }
            
            $0.centerY.equalTo(textFieldContainer)
        }
        
        arrowDownButton.snp.makeConstraints {
            $0.trailing.equalTo(textFieldContainer).offset(-4)
            $0.centerY.equalTo(textFieldContainer)
            $0.size.equalTo(30)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(titleLabel).priority(.high)
            $0.bottom.equalTo(textFieldContainer).priority(.high)
        }
    }
    
    private func setPlaceholder(_ placeholder: String?) {
        guard let placeholder else { return }
        
        let attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            .foregroundColor: UIColor.gray30
        ])
        textField.attributedPlaceholder = attributedPlaceholder
    }
}

extension Reactive where Base: EditAccountInputField {
    var text: ControlProperty<String> {
        return base.textField.rx.text.orEmpty
    }
    
    var value: Binder<String?> {
        return Binder(base) { view, text in
            view.textField.text = text
        }
    }
    
    var tap: ControlEvent<Void> {
        return base.arrowDownButton.rx.tap
    }
}
