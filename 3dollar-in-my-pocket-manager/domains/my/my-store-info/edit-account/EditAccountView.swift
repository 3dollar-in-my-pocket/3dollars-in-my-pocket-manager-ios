import UIKit

import RxSwift
import RxCocoa

final class EditAccountView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
        $0.text = String(localized: "edit_account.account_numbuer")
    }
    
    let accountInputField = EditAccountInputField(
        title: String(localized: "edit_account.account_numbuer"),
        isRedDotHidden: false,
        isRightButtonHidden: true,
        placeholder: String(localized: "edit_account.account_number_placeholder")
    )
    
    let bankInputField = EditAccountInputField(
        title: String(localized: "edit_account.bank"),
        isRedDotHidden: false,
        isRightButtonHidden: false,
        placeholder: String(localized: "edit_account.bank_placeholder")
    ).then {
        $0.textField.isUserInteractionEnabled = false
    }
    
    let nameInputField = EditAccountInputField(
        title: String(localized: "edit_account.name"),
        isRedDotHidden: false,
        isRightButtonHidden: true,
        placeholder: String(localized: "edit_account.title_placeholder")
    )
    
    let saveButton = UIButton().then {
        $0.setTitle(String(localized: "edit_account.save"), for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    fileprivate let buttonBackgroundView = UIView()
    
    override func setup() {
        backgroundColor = .white
        
        addSubViews([
            backButton,
            titleLabel,
            accountInputField,
            bankInputField,
            nameInputField,
            saveButton,
            buttonBackgroundView
        ])
    }
    
    override func bindConstraints() {
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

extension Reactive where Base: EditAccountView {
    var isEnableSaveButton: Binder<Bool> {
        return Binder(base) { view, isEnable in
            if isEnable {
                view.saveButton.backgroundColor = .green
                view.buttonBackgroundView.backgroundColor = .green
            } else {
                view.saveButton.backgroundColor = .gray30
                view.buttonBackgroundView.backgroundColor = .gray30
            }
        }
    }
}

