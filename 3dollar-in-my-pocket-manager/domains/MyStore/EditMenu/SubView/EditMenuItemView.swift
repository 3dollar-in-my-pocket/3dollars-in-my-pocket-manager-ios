import UIKit

final class EditMenuItemView: BaseView {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
        return view
    }()
    
    let cameraButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray10
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.adjustsImageWhenHighlighted = false
        
        let image = UIImage(named: "ic_camera")?
            .resizeImage(scaledTo: 28)
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .gray30
        return button
    }()
    
    private let menuNameBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .gray5
        return view
    }()
    
    let menuNameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "edit_menu_name_placeholder".localized,
            attributes: [.foregroundColor: UIColor.gray30]
        )
        textField.font = .medium(size: 14)
        textField.textColor = .gray100
        return textField
    }()
    
    private let menuPriceBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .gray5
        return view
    }()
    
    let menuPriceTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "edit_menu_price_placeholder".localized,
            attributes: [.foregroundColor: UIColor.gray30]
        )
        textField.font = .medium(size: 14)
        textField.textColor = .gray100
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    let deleteButon: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_delete"), for: .normal)
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 12)
        label.textColor = .red
        label.text = "edit_menu_warning".localized
        label.isHidden = true
        return label
    }()
    
    override func setup() {
        backgroundColor = .clear
        setupLayout()
        
    }
    
    private func setupLayout() {
        containerView.addSubViews([
            cameraButton,
            menuNameBackground,
            menuNameTextField,
            menuPriceBackground,
            menuPriceTextField,
            warningLabel
        ])
        addSubViews([
            containerView,
            deleteButon
        ])
        
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.bottom.equalTo(warningLabel).offset(12).priority(.high)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(104)
            make.height.equalTo(104)
        }
        
        menuNameBackground.snp.makeConstraints { make in
            make.leading.equalTo(cameraButton.snp.trailing).offset(12)
            make.top.equalTo(cameraButton)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(48)
        }
        
        menuNameTextField.snp.makeConstraints { make in
            make.leading.equalTo(menuNameBackground).offset(12)
            make.top.equalTo(menuNameBackground).offset(15)
            make.bottom.equalTo(menuNameBackground).offset(-15)
            make.trailing.equalTo(menuNameBackground).offset(-12)
        }
        
        menuPriceBackground.snp.makeConstraints { make in
            make.leading.equalTo(menuNameBackground)
            make.trailing.equalTo(menuNameBackground)
            make.top.equalTo(menuNameBackground.snp.bottom).offset(8)
            make.height.equalTo(menuNameBackground)
        }
        
        menuPriceTextField.snp.makeConstraints { make in
            make.leading.equalTo(menuPriceBackground).offset(12)
            make.top.equalTo(menuPriceBackground).offset(15)
            make.bottom.equalTo(menuPriceBackground).offset(-15)
            make.trailing.equalTo(menuPriceBackground).offset(-12)
        }
        
        warningLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(12)
            make.top.equalTo(cameraButton.snp.bottom).offset(8)
            make.height.equalTo(0)
        }
        
        deleteButon.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.trailing.equalToSuperview().offset(32)
        }
    }
    
    func bind(menu: BossStoreMenu) {
        if let imageUrl = menu.image?.imageUrl {
            cameraButton.setImage(urlString: imageUrl)
        } else if let image = menu.image?.image {
            cameraButton.setImage(image, for: .normal)
        }
        
        menuNameTextField.text = menu.name
        menuPriceTextField.text = menu.price == 0 ? "" : "\(menu.price)"
    }
    
    func setDeleteMode(_ isDeleteMode: Bool, animated: Bool) {
        containerView.isUserInteractionEnabled = !isDeleteMode
        
        if animated {
            UIView.transition(with: self, duration: 0.3) { [weak self] in
                self?.containerView.transform = isDeleteMode ? .init(translationX: -56, y: 0) : .identity
                self?.deleteButon.transform = isDeleteMode ? .init(translationX: -56, y: 0) : .identity
            }
        } else {
            containerView.transform = isDeleteMode ? .init(translationX: -56, y: 0) : .identity
            deleteButon.transform = isDeleteMode ? .init(translationX: -56, y: 0) : .identity
        }
    }
    
    func showWarning(_ isShow: Bool) {
        if isShow {
            containerView.layer.borderColor = UIColor.red.cgColor
            containerView.layer.borderWidth = 1
            containerView.backgroundColor = .clear
            warningLabel.isHidden = false
            warningLabel.snp.updateConstraints { make in
                make.height.equalTo(14)
            }
        } else {
            containerView.layer.borderWidth = 0
            containerView.backgroundColor = .white
            warningLabel.isHidden = true
            warningLabel.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
}

