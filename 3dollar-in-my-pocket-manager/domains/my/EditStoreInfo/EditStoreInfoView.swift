import UIKit

final class EditStoreInfoView: BaseView {
    let tapBackground = UITapGestureRecognizer()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 16)
        label.textColor = .gray100
        label.text = "edit_store_info.title".localized
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    let storeNameField = InputField(
        title: "signup_store_name".localized,
        isRequired: true,
        description: "signup_store_name_description".localized,
        placeholder: "signup_store_name_placeholder".localized
    ).then {
        $0.maxLength = 20
    }
    
    let categoryCollectionView = CategorySelectView()
    
    let photoView = EditStoreInfoPhotoView()
    
    let snsField = InputField(
        title: "edit_store_info.sns".localized,
        isRequired: false,
        placeholder: "edit_store_info.sns.placeholder".localized
    )
    
    let saveButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "edit_store_info.save".localized
        config.baseForegroundColor = UIColor(r: 251, g: 251, b: 251)
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { button in
            button.backgroundColor = button.isEnabled ? .green : .gray30
            button.titleLabel?.font = .medium(size: 16)
        }
        button.isEnabled = false
        return button
    }()
    
    let buttonBackgroundView = UIView()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        setupKeyboardEvent()
        setupLayout()
        
        self.tapBackground.rx.event
            .map { _ in Void() }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.endEditing(true)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupLayout() {
        backgroundColor = .gray0
        
        addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(15)
            $0.size.equalTo(24)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        stackView.addArrangedSubview(storeNameField)
        stackView.setCustomSpacing(32, after: storeNameField)
        stackView.addArrangedSubview(categoryCollectionView)
        stackView.setCustomSpacing(32, after: categoryCollectionView)
        stackView.addArrangedSubview(photoView)
        stackView.setCustomSpacing(32, after: photoView)
        stackView.addArrangedSubview(snsField)
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(60)
            $0.bottom.equalToSuperview().offset(-44)
        }
        
        addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        addSubview(buttonBackgroundView)
        buttonBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(saveButton.snp.bottom)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(21)
            $0.width.equalTo(UIUtils.windowBounds.width).priority(.high)
            $0.bottom.equalTo(saveButton.snp.top)
        }
    }
    
    func bind(store: BossStoreResponse, categories: [StoreFoodCategoryResponse]) {
        storeNameField.setText(text: store.name)
        categoryCollectionView.bind(categories: categories)
        categoryCollectionView.selectCategories(categories: store.categories)
        photoView.bind(images: store.representativeImages)
        snsField.setText(text: store.snsUrl)
    }
    
    func setSaveButtonEnable(_ isEnable: Bool) {
        saveButton.isEnabled = isEnable
        let backgroundColor: UIColor = isEnable ? .green : .gray30
        buttonBackgroundView.backgroundColor = backgroundColor
    }
    
    private func selectCategories(indexes: [Int]) {
        for index in indexes {
            categoryCollectionView.collectionView.selectItem(
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
