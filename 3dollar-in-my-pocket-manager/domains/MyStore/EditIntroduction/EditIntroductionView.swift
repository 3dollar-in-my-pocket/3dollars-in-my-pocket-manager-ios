import UIKit
import Combine

final class EditIntroductionView: BaseView {
    fileprivate let tapGesture = UITapGestureRecognizer()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 16)
        label.textColor = .gray100
        label.text = "edit_introduction.title".localized
        return label
    }()
    
    private let mainDescriptionLabel: UILabel = {
        let label = UILabel()
        let string = "edit_introduction.main_description".localized
        let attributedString = NSMutableAttributedString(string: string)
        
        attributedString.addAttribute(
            .font,
            value: UIFont.bold(size: 24) as Any,
            range: (string as NSString).range(of: "edit_introduction.main_description.bold".localized)
        )
        
        label.font = .regular(size: 24)
        label.textColor = .black
        label.numberOfLines = 0
        label.attributedText = attributedString
        return label
    }()
    
    private let subDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        label.text = "edit_introduction.sub_description".localized
        return label
    }()
    
    private let textViewBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .gray5
        return view
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .gray100
        textView.font = .medium(size: 14)
        textView.backgroundColor = .clear
        return textView
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("edit_introdution.edit_button".localized, for: .normal)
        button.titleLabel?.font = .medium(size: 16)
        button.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        button.setBackgroundColor(color: .green, forState: .normal)
        button.setBackgroundColor(color: .gray30, forState: .disabled)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    private let buttonBackgroundView = UIView()
    
    override func setup() {
        addGestureRecognizer(tapGesture)
        backgroundColor = UIColor(r: 251, g: 251, b: 251)
        setupLayout()
        
        tapGesture.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: EditIntroductionView, _) in
                owner.endEditing(true)
            }
            .store(in: &cancellables)
    }
    
    private func setupLayout() {
        addSubViews([
            backButton,
            titleLabel,
            mainDescriptionLabel,
            subDescriptionLabel,
            textViewBackground,
            textView,
            editButton,
            buttonBackgroundView
        ])
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }
        
        mainDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(backButton.snp.bottom).offset(53)
        }
        
        subDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(mainDescriptionLabel.snp.bottom).offset(8)
        }
        
        textViewBackground.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(subDescriptionLabel.snp.bottom).offset(24)
            make.height.equalTo(274)
        }
        
        textView.snp.makeConstraints { make in
            make.left.equalTo(textViewBackground).offset(12)
            make.right.equalTo(textViewBackground).offset(-12)
            make.top.equalTo(textViewBackground).offset(15)
            make.bottom.equalTo(textViewBackground).offset(-15)
        }
        
        editButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackgroundView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(editButton.snp.bottom)
        }
    }
    
    func bind(introduction: String?) {
        textView.text = introduction
    }
    
    func setEditButtonEnable(_ isEnable: Bool) {
        let color: UIColor = isEnable ? .green : .gray30
        editButton.isEnabled = isEnable
        buttonBackgroundView.backgroundColor = color
    }
}
