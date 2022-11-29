import UIKit

final class EditScheduleView: BaseView {
    private let tapBackgroundGesture = UITapGestureRecognizer()
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
        $0.text = "edit_schedule_title".localized
    }
    
    private let mainDescriptionLabel = UILabel().then {
        $0.font = .regular(size: 24)
        $0.textColor = .black
        
        let string = "edit_schedule_main_description".localized
        let attributedString = NSMutableAttributedString(string: string)
        
        attributedString.addAttribute(
            .font,
            value: UIFont.bold(size: 24) as Any,
            range: (string as NSString).range(of: "영업 요일")
        )
        $0.attributedText = attributedString
    }
    
    private let subDescriptionLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .black
        
        let text = "edit_schedule_sub_description".localized
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(
            .font,
            value: UIFont.bold(size: 14) as Any,
            range: (text as NSString).range(of: "휴무")
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.red,
            range: (text as NSString).range(of: "휴무")
        )
        $0.attributedText = attributedString
    }
    
    let weekDayStackView = WeekDayStackView()
    
    let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.register(
            EditScheduleTableViewCell.self,
            forCellReuseIdentifier: EditScheduleTableViewCell.registerId
        )
        $0.rowHeight = EditScheduleTableViewCell.size.height
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("edit_schedule_save".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        $0.setBackgroundColor(color: .green, forState: .normal)
        $0.setBackgroundColor(color: .gray30, forState: .disabled)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        self.addGestureRecognizer(self.tapBackgroundGesture)
        self.backgroundColor = .gray0
        self.setupKeyboardEvent()
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.mainDescriptionLabel,
            self.subDescriptionLabel,
            self.weekDayStackView,
            self.tableView,
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
            make.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.mainDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.backButton.snp.bottom).offset(53)
        }
        
        self.subDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.mainDescriptionLabel.snp.bottom).offset(4)
        }
        
        self.weekDayStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.subDescriptionLabel.snp.bottom).offset(16)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.weekDayStackView.snp.bottom).offset(24)
            make.bottom.equalTo(self.saveButton.snp.top)
        }
        
        self.saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-64)
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
        
        var contentInset = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 10
        self.tableView.contentInset = contentInset
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.tableView.contentInset = contentInset
    }
}
