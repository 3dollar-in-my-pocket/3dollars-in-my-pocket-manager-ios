import UIKit

final class EditMenuTableViewCell: BaseTableViewCell {
    static let registerId = "\(EditMenuTableViewCell.self)"
    static let height: CGFloat = 144
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .white
    }
    
    let cameraButton = UIButton().then {
        $0.backgroundColor = .gray10
        $0.setImage(UIImage(named: "ic_cemera"), for: .normal)
        $0.contentMode = .scaleAspectFill
    }
    
    private let menuNameTextFieldBackground = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .gray5
    }
    
    let menuNameTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "메뉴를 입력해주세요.",
            attributes: [.foregroundColor: UIColor.gray30]
        )
        $0.font = .medium(size: 14)
        $0.textColor = .gray100
    }
    
    private let menuPriceTextFieldBackground = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .gray5
    }
    
    let menuPriceTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "가격을 입력해 주세요",
            attributes: [.foregroundColor: UIColor.gray30]
        )
        $0.font = .medium(size: 14)
        $0.textColor = .gray100
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cameraButton.setImage(nil, for: .normal)
    }
    
    override func setup() {
        self.selectionStyle = .none
        self.addSubViews([
            self.containerView,
            self.cameraButton,
            self.menuNameTextFieldBackground,
            self.menuNameTextField,
            self.menuPriceTextFieldBackground,
            self.menuPriceTextField
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
        }
        
        self.cameraButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.top.equalTo(self.containerView).offset(12)
            make.bottom.equalTo(self.containerView).offset(-12)
            make.width.equalTo(self.cameraButton.snp.height)
        }
        
        self.menuNameTextFieldBackground.snp.makeConstraints { make in
            make.left.equalTo(self.cameraButton.snp.right).offset(12)
            make.top.equalTo(self.cameraButton)
            make.right.equalTo(self.containerView).offset(-12)
            make.height.equalTo(48)
        }
        
        self.menuNameTextField.snp.makeConstraints { make in
            make.left.equalTo(self.menuNameTextFieldBackground).offset(12)
            make.top.equalTo(self.menuNameTextFieldBackground).offset(15)
            make.bottom.equalTo(self.menuNameTextFieldBackground).offset(-15)
            make.right.equalTo(self.menuNameTextFieldBackground).offset(-12)
        }
        
        self.menuPriceTextFieldBackground.snp.makeConstraints { make in
            make.left.equalTo(self.menuNameTextFieldBackground)
            make.right.equalTo(self.menuPriceTextFieldBackground)
            make.top.equalTo(self.menuPriceTextFieldBackground.snp.bottom).offset(8)
            make.height.equalTo(self.menuNameTextFieldBackground)
        }
    }
    
    func bind(menu: Menu) {
    }
}

