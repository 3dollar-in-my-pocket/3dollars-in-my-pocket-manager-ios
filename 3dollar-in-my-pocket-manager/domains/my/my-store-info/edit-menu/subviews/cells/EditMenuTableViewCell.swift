import UIKit

import RxSwift

final class EditMenuTableViewCell: BaseTableViewCell {
    static let registerId = "\(EditMenuTableViewCell.self)"
    static let height: CGFloat = 144
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .white
    }
    
    let cameraButton = UIButton().then {
        $0.backgroundColor = .gray10
        $0.imageView?.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.setImage(UIImage(named: "ic_camera"), for: .normal)
    }
    
    private let menuNameTextFieldBackground = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .gray5
    }
    
    let menuNameTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "edit_menu_name_placeholder".localized,
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
            string: "edit_menu_price_placeholder".localized,
            attributes: [.foregroundColor: UIColor.gray30]
        )
        $0.font = .medium(size: 14)
        $0.textColor = .gray100
        $0.keyboardType = .decimalPad
    }
    
    let deleteButon = UIButton().then {
        $0.setImage(UIImage(named: "ic_delete"), for: .normal)
    }
    
    private let warningLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = .red
        $0.text = "edit_menu_warning".localized
        $0.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cameraButton.setImage(UIImage(named: "ic_camera"), for: .normal)
    }
    
    override func setup() {
        self.contentView.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.containerView.addSubViews([
            self.cameraButton,
            self.menuNameTextFieldBackground,
            self.menuNameTextField,
            self.menuPriceTextFieldBackground,
            self.menuPriceTextField,
            self.warningLabel
        ])
        self.addSubViews([
            self.containerView,
            self.deleteButon
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
            make.bottom.equalTo(self.warningLabel).offset(12).priority(.high)
        }
        
        self.cameraButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(104)
            make.height.equalTo(104)
        }
        
        self.menuNameTextFieldBackground.snp.makeConstraints { make in
            make.left.equalTo(self.cameraButton.snp.right).offset(12)
            make.top.equalTo(self.cameraButton)
            make.right.equalToSuperview().offset(-12)
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
            make.right.equalTo(self.menuNameTextFieldBackground)
            make.top.equalTo(self.menuNameTextFieldBackground.snp.bottom).offset(8)
            make.height.equalTo(self.menuNameTextFieldBackground)
        }
        
        self.menuPriceTextField.snp.makeConstraints { make in
            make.left.equalTo(self.menuPriceTextFieldBackground).offset(12)
            make.top.equalTo(self.menuPriceTextFieldBackground).offset(15)
            make.bottom.equalTo(self.menuPriceTextFieldBackground).offset(-15)
            make.right.equalTo(self.menuPriceTextFieldBackground).offset(-12)
        }
        
        self.warningLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.top.equalTo(self.cameraButton.snp.bottom).offset(8)
            make.height.equalTo(0)
        }
        
        self.deleteButon.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.right.equalToSuperview().offset(32)
        }
    }
    
    func bind(menu: Menu, isDeleteMode: Bool, isInvalid: Bool) {
        if !menu.imageUrl.isEmpty {
            self.cameraButton.setImage(urlString: menu.imageUrl)
        }
        
        if let photo = menu.photo {
            self.cameraButton.setImage(photo, for: .normal)
        }
        
        self.menuNameTextField.text = menu.name
        self.menuPriceTextField.text = menu.price == 0 ? "" : "\(menu.price)"
        self.containerView.isUserInteractionEnabled = !isDeleteMode
        self.setInvalidLayout(isInvalid: isInvalid)
        
        UIView.transition(with: self, duration: 0.3) { [weak self] in
            self?.containerView.transform
            = isDeleteMode ? .init(translationX: -56, y: 0) : .identity
            self?.deleteButon.transform
            = isDeleteMode ? .init(translationX: -56, y: 0) : .identity
        }
    }
    
    private func setInvalidLayout(isInvalid: Bool) {
        if isInvalid {
            self.containerView.layer.borderColor = UIColor.red.cgColor
            self.containerView.layer.borderWidth = 1
            self.containerView.backgroundColor = .clear
            self.warningLabel.isHidden = false
            self.warningLabel.snp.updateConstraints { make in
                make.height.equalTo(14)
            }
        } else {
            self.containerView.layer.borderWidth = 0
            self.containerView.backgroundColor = .white
            self.warningLabel.isHidden = true
            self.warningLabel.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
        
    }
}

