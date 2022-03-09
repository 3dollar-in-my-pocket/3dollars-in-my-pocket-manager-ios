import UIKit

final class SignupView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "signup_title".localized
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let containerView = UIView()
    
    private let descriptionLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = .gray95
        $0.numberOfLines = 0
        $0.text = "signup_description".localized
        $0.setLineHeight(lineHeight: 31)
    }
    
    private let roundedBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor(r: 0, g: 198, b: 103).cgColor
        $0.layer.shadowOpacity = 0.04
    }
    
    let ownerNameField = SignupInputField(
        title: "signup_owner_name".localized,
        isRequired: true,
        placeholder: "signup_owner_name_placeholder".localized
    )
    
    let storeNameField = SignupInputField(
        title: "signup_store_name".localized,
        isRequired: true,
        description: "signup_store_name_description".localized,
        placeholder: "signup_store_name_placeholder".localized
    ).then {
        $0.maxLength = 20
    }
    
    let registerationNumberField = SignupInputField(
        title: "signup_registeration_number_title".localized,
        isRequired: true,
        description: "signup_registeration_number_description".localized,
        placeholder: "signup_registeration_number_placeholder".localized
    ).then {
        $0.keyboardType = .numberPad
    }
    
    let phoneNumberField = SignupInputField(
        title: "signup_phone_number_title".localized,
        isRequired: true,
        description: "signup_phone_number_description".localized,
        placeholder: "signup_phone_number_placeholder".localized
    ).then {
        $0.keyboardType = .numberPad
    }
    
    override func setup() {
        self.backgroundColor = .gray0
        self.containerView.addSubViews([
            self.descriptionLabel,
            self.roundedBackgroundView,
            self.ownerNameField,
            self.storeNameField,
            self.registerationNumberField,
            self.phoneNumberField
        ])
        self.scrollView.addSubview(self.containerView)
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.scrollView
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.width.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.backButton.snp.bottom).offset(21)
            make.bottom.equalToSuperview()
        }
        
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.top.equalTo(self.descriptionLabel).priority(.high)
            make.bottom.equalTo(self.phoneNumberField).priority(.high)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(38)
        }
        
        self.roundedBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(21)
            make.bottom.equalTo(self.phoneNumberField)
        }
        
        self.ownerNameField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.roundedBackgroundView).offset(32)
        }
        
        self.storeNameField.snp.makeConstraints { make in
            make.left.equalTo(self.ownerNameField)
            make.right.equalTo(self.ownerNameField)
            make.top.equalTo(self.ownerNameField.snp.bottom).offset(32)
        }
        
        self.registerationNumberField.snp.makeConstraints { make in
            make.left.equalTo(self.ownerNameField)
            make.right.equalTo(self.ownerNameField)
            make.top.equalTo(self.storeNameField.snp.bottom).offset(32)
        }
        
        self.phoneNumberField.snp.makeConstraints { make in
            make.left.equalTo(self.ownerNameField)
            make.right.equalTo(self.ownerNameField)
            make.top.equalTo(self.registerationNumberField.snp.bottom).offset(32)
        }
    }
}
