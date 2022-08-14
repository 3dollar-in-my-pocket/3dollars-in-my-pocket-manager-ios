import UIKit

import Base

final class EditStoreInfoView: BaseView {
    let tapBackground = UITapGestureRecognizer()
    
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
    
    let storeNameField = InputField(
        title: "signup_store_name".localized,
        isRequired: true,
        description: "signup_store_name_description".localized,
        placeholder: "signup_store_name_placeholder".localized
    ).then {
        $0.maxLength = 20
    }
    
    let categoryCollectionView = CategorySelectView()
    
    let photoView = PhotoUploadView(type: .edit)
    
    let snsField = InputField(
        title: "edit_store_info_sns".localized,
        isRequired: false,
        placeholder: "edit_introduction_sns".localized
    )
    
    let saveButton = UIButton().then {
        $0.setTitle("edit_store_info_save".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        $0.setBackgroundColor(color: .green, forState: .normal)
        $0.setBackgroundColor(color: .gray30, forState: .disabled)
        $0.isEnabled = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        self.roundedBackgroundView.addGestureRecognizer(self.tapBackground)
        self.setupKeyboardEvent()
        self.backgroundColor = .gray0
        self.containerView.addSubViews([
            self.roundedBackgroundView,
            self.storeNameField,
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
        self.tapBackground.rx.event
            .map { _ in Void() }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.endEditing(true)
            })
            .disposed(by: self.disposeBag)
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
        
        self.categoryCollectionView.snp.makeConstraints { make in
            make.left.equalTo(self.storeNameField)
            make.right.equalTo(self.storeNameField)
            make.top.equalTo(self.storeNameField.snp.bottom).offset(32)
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
    
    func bind(store: Store) {
        self.storeNameField.setText(text: store.name)
        self.photoView.setImage(imageUrl: store.imageUrl)
        self.snsField.setText(text: store.snsUrl)
    }
    
    func selectCategories(indexes: [Int]) {
        for index in indexes {
            self.categoryCollectionView.categoryCollectionView.selectItem(
                at: IndexPath(row: index, section: 0),
                animated: true,
                scrollPosition: .centeredVertically
            )
        }
    }
    
    private func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onShowKeyboard(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onHideKeyboard(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func onShowKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame
        = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.convert(keyboardFrame, from: nil)
        
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 10
        self.scrollView.contentInset = contentInset
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.scrollView.contentInset = contentInset
    }
}
