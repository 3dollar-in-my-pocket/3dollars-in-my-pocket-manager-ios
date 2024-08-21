import UIKit

final class EditAccountView: BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 16)
        label.textColor = .gray100
        label.text = String(localized: "edit_account.account_numbuer")
        return label
    }()
    
    let accountInputField = EditAccountInputField(
        title: String(localized: "edit_account.account_numbuer"),
        isRedDotHidden: false,
        isRightButtonHidden: true,
        placeholder: String(localized: "edit_account.account_number_placeholder")
    )
    
    let bankInputField: EditAccountInputField = {
        let inputField = EditAccountInputField(
            title: String(localized: "edit_account.bank"),
            isRedDotHidden: false,
            isRightButtonHidden: false,
            placeholder: String(localized: "edit_account.bank_placeholder")
        )
        inputField.textField.isUserInteractionEnabled = false
        return inputField
    }()
    
    let nameInputField = EditAccountInputField(
        title: String(localized: "edit_account.name"),
        isRedDotHidden: false,
        isRightButtonHidden: true,
        placeholder: String(localized: "edit_account.title_placeholder")
    )
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "edit_account.save"), for: .normal)
        button.titleLabel?.font = .medium(size: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    fileprivate let buttonBackgroundView = UIView()
    
    override func setup() {
        backgroundColor = .white
        setupLayout()
    }
    
    func setSaveButtonEnable(_ isEnable: Bool) {
        if isEnable {
            saveButton.backgroundColor = .green
            buttonBackgroundView.backgroundColor = .green
        } else {
            saveButton.backgroundColor = .gray30
            buttonBackgroundView.backgroundColor = .gray30
        }
    }
    
    private func setupLayout() {
        addSubViews([
            backButton,
            titleLabel,
            accountInputField,
            bankInputField,
            nameInputField,
            saveButton,
            buttonBackgroundView
        ])
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(15)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        accountInputField.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(53)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        
        bankInputField.snp.makeConstraints {
            $0.top.equalTo(accountInputField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        nameInputField.snp.makeConstraints {
            $0.top.equalTo(bankInputField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}
