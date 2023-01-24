import UIKit

import RxSwift
import RxCocoa

final class EditMenuView: BaseView {
    private let tapBackgroundGesture = UITapGestureRecognizer()
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
        $0.text = "edit_menu_title".localized
    }
    
    private let menuCountLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = .gray30
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle("edit_menu_delete".localized, for: .normal)
        $0.titleLabel?.font = .bold(size: 14)
        $0.setTitleColor(.red, for: .normal)
    }
    
    let menuTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.estimatedRowHeight = EditMenuTableViewCell.height
        $0.register(
            EditMenuTableViewCell.self,
            forCellReuseIdentifier: EditMenuTableViewCell.registerId
        )
        $0.contentInset = .init(top: 0, left: 0, bottom: 72, right: 0)
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("edit_menu_save".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        $0.setBackgroundColor(color: .green, forState: .normal)
        $0.setBackgroundColor(color: .gray30, forState: .disabled)
    }
    
    let tableViewFooterView = EditMenuTableFooterView(
        frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56)
    )
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        self.addGestureRecognizer(self.tapBackgroundGesture)
        self.backgroundColor = .gray0
        self.menuTableView.tableFooterView = self.tableViewFooterView
        self.setupKeyboardEvent()
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.menuCountLabel,
            self.deleteButton,
            self.menuTableView,
            self.saveButton
        ])
        
        self.tapBackgroundGesture.rx.event
            .asDriver()
            .throttle(.milliseconds(500))
            .drive(onNext: { [weak self] _ in
                self?.endEditing(true)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(25)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.menuCountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.backButton.snp.bottom).offset(63)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.menuCountLabel)
        }
        
        self.menuTableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.saveButton.snp.top)
            make.top.equalTo(self.menuCountLabel.snp.bottom).offset(16)
        }
        
        self.saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-64)
        }
    }
    
    func setPhotoInCell(index: Int, photo: UIImage) {
        guard let cell = self.menuTableView.cellForRow(
            at: IndexPath(row: index, section: 0)
        ) as? EditMenuTableViewCell else { return }
        
        cell.cameraButton.setImage(photo, for: .normal)
    }
    
    fileprivate func setMenuCount(count: Int) {
        let text = "\(count)/20개의 메뉴가 등록되어 있습니다."
        let attributedTextRange = (text as NSString).range(of: "개의 메뉴가 등록되어 있습니다.")
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.gray70,
            range: attributedTextRange
        )
        
        self.menuCountLabel.attributedText = attributedString
    }
    
    fileprivate func setDeleteMode(isDeleteMode: Bool) {
        if isDeleteMode {
            self.deleteButton.setTitle("edit_menu_delete_all".localized, for: .normal)
            self.saveButton.setTitle("edit_menu_finish_delete".localized, for: .normal)
        } else {
            self.deleteButton.setTitle("edit_menu_delete".localized, for: .normal)
            self.saveButton.setTitle("edit_menu_save".localized, for: .normal)
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
        
        var contentInset = self.menuTableView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 10
        self.menuTableView.contentInset = contentInset
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.menuTableView.contentInset = contentInset
    }
}


extension Reactive where Base: EditMenuView {
    var menuCount: Binder<Int> {
        return Binder(self.base) { view, count in
            view.setMenuCount(count: count)
        }
    }
    
    var isDeleteMode: Binder<Bool> {
        return Binder(self.base) { view, isDeleteMode in
            view.setDeleteMode(isDeleteMode: isDeleteMode)
        }
    }
}
