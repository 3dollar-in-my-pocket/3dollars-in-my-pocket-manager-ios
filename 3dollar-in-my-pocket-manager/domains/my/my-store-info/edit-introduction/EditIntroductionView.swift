import UIKit

final class EditIntroductionView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
        $0.text = "edit_introduction_title".localized
    }
    
    private let mainDescriptionLabel = UILabel().then {
        let string = "edit_introduction_main_description".localized
        let attributedString = NSMutableAttributedString(string: string)
        
        attributedString.addAttribute(
            .font,
            value: UIFont.bold(size: 24) as Any,
            range: (string as NSString).range(of: "손님들에게 하고 싶은 말")
        )
        
        $0.font = .regular(size: 24)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.attributedText = attributedString
    }
    
    private let subDescriptionLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .gray50
        $0.text = "edit_introduction_sub_description".localized
    }
    
    private let textViewBackground = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .gray5
    }
    
    private let textView = UITextView().then {
        $0.textColor = .gray100
        $0.font = .medium(size: 14)
        $0.backgroundColor = .clear
    }
    
    let editButton = UIButton().then {
        $0.setTitle("edit_introdution_edit_button".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        $0.setBackgroundColor(color: .green, forState: .normal)
    }
    
    override func setup() {
        self.backgroundColor = UIColor(r: 251, g: 251, b: 251)
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.mainDescriptionLabel,
            self.subDescriptionLabel,
            self.textViewBackground,
            self.textView,
            self.editButton
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.mainDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.backButton.snp.bottom).offset(53)
        }
        
        self.subDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.mainDescriptionLabel.snp.bottom).offset(8)
        }
        
        self.textViewBackground.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.subDescriptionLabel.snp.bottom).offset(24)
            make.height.equalTo(274)
        }
        
        self.textView.snp.makeConstraints { make in
            make.left.equalTo(self.textViewBackground).offset(12)
            make.right.equalTo(self.textViewBackground).offset(-12)
            make.top.equalTo(self.textViewBackground).offset(15)
            make.bottom.equalTo(self.textViewBackground).offset(-15)
        }
        
        self.editButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-64)
        }
    }
}
