import UIKit

final class EditAccountInputField: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray100
        return label
    }()
    
    private let redDot: UIView = {
        let view = UIView()
        view.backgroundColor = .pink
        view.layer.cornerRadius = 2
        view.isHidden = true
        return view
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 8
        return view
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .gray100
        textField.font = .medium(size: 14)
        return textField
    }()
    
    let arrowDownButton: UIButton = {
        let button = UIButton()
        let icon = UIImage(named: "ic_arrow_down")?
            .withRenderingMode(.alwaysTemplate)
        
        button.setImage(icon, for: .normal)
        button.tintColor = .gray50
        button.isHidden = true
        return button
    }()
    
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
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([
            titleLabel,
            redDot,
            textFieldContainer,
            textField,
            arrowDownButton
        ])
        
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
