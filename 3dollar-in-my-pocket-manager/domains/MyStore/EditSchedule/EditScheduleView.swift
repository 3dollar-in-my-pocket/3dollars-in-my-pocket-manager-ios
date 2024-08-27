import UIKit

final class EditScheduleView: BaseView {
    private let tapBackgroundGesture = UITapGestureRecognizer()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 16)
        label.textColor = .gray100
        label.text = "edit_schedule_title".localized
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private let mainDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 24)
        label.textColor = .black
        
        let string = "edit_schedule_main_description".localized
        let attributedString = NSMutableAttributedString(string: string)
        
        attributedString.addAttribute(
            .font,
            value: UIFont.bold(size: 24) as Any,
            range: (string as NSString).range(of: "영업 요일")
        )
        label.attributedText = attributedString
        return label
    }()
    
    private let subDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        
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
        label.attributedText = attributedString
        return label
    }()
    
    let weekDayStackView = WeekDayStackView()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("edit_schedule_save".localized, for: .normal)
        button.titleLabel?.font = .medium(size: 16)
        button.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        button.setBackgroundColor(color: .green, forState: .normal)
        button.setBackgroundColor(color: .gray30, forState: .disabled)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let buttonBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        addGestureRecognizer(tapBackgroundGesture)
        backgroundColor = .gray0
        setupKeyboardEvent()
        setupLayout()
        
        tapBackgroundGesture.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: EditScheduleView, _) in
                owner.endEditing(true)
            }
            .store(in: &cancellables)
    }
    
    func clearItemViews() {
        stackView.arrangedSubviews
            .compactMap { $0 as? EditScheduleItemView }
            .forEach { $0.removeFromSuperview() }
    }
    
    private func setupLayout() {
        addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(15)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        addSubview(buttonBackground)
        buttonBackground.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(saveButton.snp.bottom)
        }
        
        stackView.addArrangedSubview(mainDescriptionLabel)
        stackView.setCustomSpacing(4, after: mainDescriptionLabel)
        
        stackView.addArrangedSubview(subDescriptionLabel)
        stackView.setCustomSpacing(16, after: subDescriptionLabel)
        
        stackView.addArrangedSubview(weekDayStackView)
        stackView.setCustomSpacing(40, after: weekDayStackView)
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(32)
            $0.width.equalTo(UIUtils.windowBounds.width - 48)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(backButton.snp.bottom).offset(21)
            $0.bottom.equalTo(saveButton.snp.top)
            $0.width.equalTo(UIUtils.windowBounds.width - 48)
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
