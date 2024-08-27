import UIKit

final class EditMenuView: BaseView {
    private let tapBackgroundGesture = UITapGestureRecognizer()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 16)
        label.textColor = .gray100
        label.text = "edit_menu_title".localized
        return label
    }()
    
    let scrollView = UIScrollView()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    let headerView = EditMenuHeaderView()
    
    let addMenuButton = AddMenuButton()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("edit_menu_save".localized, for: .normal)
        button.titleLabel?.font = .medium(size: 16)
        button.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        button.setBackgroundColor(color: .green, forState: .normal)
        button.setBackgroundColor(color: .gray30, forState: .disabled)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let buttonBackground = UIView()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        addGestureRecognizer(tapBackgroundGesture)
        backgroundColor = .gray0
        setupKeyboardEvent()
        setupLayout()
        
        tapBackgroundGesture.rx.event
            .asDriver()
            .throttle(.milliseconds(500))
            .drive(onNext: { [weak self] _ in
                self?.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        scrollView.addSubview(stackView)
        addSubViews([
            backButton,
            titleLabel,
            scrollView,
            saveButton,
            buttonBackground
        ])
        
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(25)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.top)
            $0.top.equalTo(backButton.snp.bottom).offset(21)
            $0.width.equalTo(UIUtils.windowBounds.width)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(42)
            $0.width.equalTo(UIUtils.windowBounds.width)
        }
        
        saveButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(saveButton.snp.bottom)
        }
    }
    
    func bind(menuItemViews: [EditMenuItemView]) {
        clearStackView()
        stackView.addArrangedSubview(headerView)
        stackView.setCustomSpacing(16, after: headerView)
        
        for (index, menuItemView) in menuItemViews.enumerated() {
            stackView.addArrangedSubview(menuItemView)
            
            if index == menuItemViews.count - 1 {
                stackView.setCustomSpacing(24, after: menuItemView)
            } else {
                stackView.setCustomSpacing(16, after: menuItemView)
            }
        }
        
        stackView.addArrangedSubview(addMenuButton)
    }
    
    func setSaveButtonEnable(_ isEnable: Bool) {
        saveButton.isEnabled = isEnable
        let color: UIColor = isEnable ? .green : .gray30
        buttonBackground.backgroundColor = color
    }
    
    func setDeleteMode(isDeleteMode: Bool) {
        headerView.setDeleteMode(isDeleteMode)
        if isDeleteMode {
            saveButton.setTitle("edit_menu_finish_delete".localized, for: .normal)
        } else {
            saveButton.setTitle("edit_menu_save".localized, for: .normal)
        }
        addMenuButton.isHidden = isDeleteMode
    }
    
    private func clearStackView() {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
//    func setPhotoInCell(index: Int, photo: UIImage) {
//        guard let cell = menuTableView.cellForRow(
//            at: IndexPath(row: index, section: 0)
//        ) as? EditMenuTableViewCell else { return }
//        
//        cell.cameraButton.setImage(photo, for: .normal)
//    }
    
    
    
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
        keyboardFrame = convert(keyboardFrame, from: nil)
        
        var contentInset = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 10
        scrollView.contentInset = contentInset
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        scrollView.contentInset = contentInset
    }
}
