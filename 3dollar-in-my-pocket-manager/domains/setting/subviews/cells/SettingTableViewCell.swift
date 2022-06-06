import UIKit

final class SettingTableViewCell: BaseTableViewCell {
    static let registerId = "\(SettingTableViewCell.self)"
    static let height: CGFloat = 66
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray90
        $0.layer.cornerRadius = 12
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    private let socialTypeImage = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = .white
    }
    
    private let rightLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = .gray30
    }
    
    private let rightArrowImage = UIImageView().then {
        $0.image = UIImage(named: "ic_arrow_right")
    }
    
    let rightButton = UIButton().then {
        $0.titleLabel?.font = .regular(size: 12)
        $0.setTitleColor(.red, for: .normal)
        $0.setTitle("setting_logout".localized, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = true
        self.addSubViews([
            self.containerView,
            self.stackView,
            self.rightLabel,
            self.rightArrowImage,
            self.rightButton
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview()
        }
        
        self.stackView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.centerY.equalTo(self.containerView)
        }
        
        self.socialTypeImage.snp.makeConstraints { make in
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.rightLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.rightArrowImage.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.rightButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
        }
    }
    
    func bind(cellType: SettingCellType) {
        self.titleLabel.text = cellType.title
        switch cellType {
        case .registerationNumber(let string):
            self.stackView.addArrangedSubview(self.titleLabel)
            self.rightLabel.text = string
            self.rightLabel.isHidden = false
            self.rightButton.isHidden = true
            self.rightArrowImage.isHidden = true
            
        case .contact:
            self.stackView.addArrangedSubview(self.titleLabel)
            self.rightLabel.isHidden = true
            self.rightButton.isHidden = true
            self.rightArrowImage.isHidden = false
            
        case .faq:
            self.stackView.addArrangedSubview(self.titleLabel)
            self.rightLabel.isHidden = true
            self.rightButton.isHidden = true
            self.rightArrowImage.isHidden = false
            
        case .privacy:
            self.stackView.addArrangedSubview(self.titleLabel)
            self.rightLabel.isHidden = true
            self.rightButton.isHidden = true
            self.rightArrowImage.isHidden = false
            
        case .signout(let socialType):
            self.stackView.addArrangedSubview(self.socialTypeImage)
            self.stackView.addArrangedSubview(self.titleLabel)
            self.titleLabel.text = "\(socialType.title) 계정 회원"
            self.socialTypeImage.image = socialType.iconImage
            self.rightLabel.isHidden = true
            self.rightButton.isHidden = false
            self.rightArrowImage.isHidden = true
        }
    }
}
