import UIKit

import RxSwift
import RxCocoa

final class CouponNameInputField: BaseView {
    var maxLength: Int? {
        willSet(newValue) {
            textField.maxLength = newValue
            textMaxCountLabel.text = "/\(newValue ?? 0)"
        }
    }
    
    var keyboardType: UIKeyboardType? {
        willSet(newValue) {
            textField.keyboardType = newValue
        }
    }
    
    var format: String? {
        willSet {
            textField.format = newValue
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 16)
        label.textColor = .gray95
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray50
        return label
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.font = .bold(size: 12)
        return label
    }()
    
    private let textMaxCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .bold(size: 12)
        return label
    }()
    
    let textField: TextField
    
    init(
        title: String,
        description: String,
        placeholder: String
    ) {
        self.textField = TextField(placeholder: placeholder)
        super.init(frame: .zero)
        
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        setupLayout()
        bind()
    }
    
    private func setupLayout() {
        addSubViews([
            titleLabel,
            descriptionLabel,
            textCountLabel,
            textMaxCountLabel,
            textField
        ])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(24)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(24)
        }
        
        textCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(descriptionLabel)
            $0.trailing.equalTo(textMaxCountLabel.snp.leading)
        }
        
        textMaxCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(descriptionLabel)
            $0.right.equalToSuperview().offset(-24)
        }
        
        textField.snp.makeConstraints {
            $0.left.equalTo(descriptionLabel)
            $0.right.equalToSuperview().offset(-24)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(10)
        }
        
        snp.makeConstraints { make in
            make.bottom.equalTo(textField).priority(.high)
        }
    }
    
    func setText(text: String?) {
        textField.setText(text: text)
    }
    
    private func bind() {
        textField.textField.textPublisher
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                
                textCountLabel.text = "\(text?.count ?? 0)"
            }
            .store(in: &cancellables)
    }
}

extension Reactive where Base: CouponNameInputField {
    var text: ControlProperty<String> {
        return base.textField.rx.text
    }
}
