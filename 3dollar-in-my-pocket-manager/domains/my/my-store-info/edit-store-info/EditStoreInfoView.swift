import UIKit

final class EditStoreInfoView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
        $0.text = "edit_store_info_title".localized
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let containerView = UIView()
    
    private let roundedBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.cornerRadius = 24
        $0.layer.shadowColor = UIColor(r: 0, g: 198, b: 103).cgColor
        $0.layer.shadowOpacity = 0.04
    }
    
    let storeNameField = SignupInputField(
        title: "signup_store_name".localized,
        isRequired: true,
        description: "signup_store_name_description".localized,
        placeholder: "signup_store_name_placeholder".localized
    ).then {
        $0.maxLength = 20
    }
    
    let phoneNumberField = SignupInputField(
        title: "signup_phone_number_title".localized,
        isRequired: true,
        description: "signup_phone_number_description".localized,
        placeholder: "signup_phone_number_placeholder".localized
    ).then {
        $0.keyboardType = .numberPad
        $0.format = "XXX-XXXX-XXXX"
    }
    
    let categoryCollectionView = SignupCategorySelectView()
    
    let photoView = SignupPhotoView()
    
    let snsField = SignupInputField(
        title: "edit_store_info_sns".localized,
        isRequired: false
    )
    
    let saveButton = UIButton().then {
        $0.setTitle("edit_store_info_save".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        $0.setBackgroundColor(color: .green, forState: .normal)
        $0.setBackgroundColor(color: .gray30, forState: .disabled)
        $0.isEnabled = false
    }
    
    override func setup() {
        self.backgroundColor = .gray0
        self.containerView.addSubViews([
            self.roundedBackgroundView,
            self.storeNameField,
            self.phoneNumberField,
            self.categoryCollectionView,
            self.photoView,
            self.snsField
        ])
        self.scrollView.addSubview(self.containerView)
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.scrollView,
            self.saveButton
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
            make.bottom.equalTo(self.saveButton.snp.top)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.top.equalTo(self.roundedBackgroundView).priority(.high)
            make.bottom.equalTo(self.roundedBackgroundView).priority(.high)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        self.roundedBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.bottom.equalTo(self.snsField).offset(44)
        }
        
        self.storeNameField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.roundedBackgroundView).offset(32)
        }
        
        self.phoneNumberField.snp.makeConstraints { make in
            make.left.equalTo(self.storeNameField)
            make.right.equalTo(self.storeNameField)
            make.top.equalTo(self.storeNameField.snp.bottom).offset(32)
        }
        
        self.categoryCollectionView.snp.makeConstraints { make in
            make.left.equalTo(self.storeNameField)
            make.right.equalTo(self.storeNameField)
            make.top.equalTo(self.phoneNumberField.snp.bottom).offset(32)
        }
        
        self.photoView.snp.makeConstraints { make in
            make.left.equalTo(self.storeNameField)
            make.right.equalTo(self.storeNameField)
            make.top.equalTo(self.categoryCollectionView.snp.bottom).offset(32)
        }
        
        self.snsField.snp.makeConstraints { make in
            make.left.equalTo(self.storeNameField)
            make.right.equalTo(self.storeNameField)
            make.top.equalTo(self.photoView.snp.bottom).offset(32)
        }
        
        self.saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(82)
        }
    }
}
