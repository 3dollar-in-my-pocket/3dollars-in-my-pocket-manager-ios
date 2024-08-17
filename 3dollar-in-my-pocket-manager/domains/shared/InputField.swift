import UIKit

import RxSwift
import RxCocoa

final class InputField: BaseView {
    var maxLength: Int? {
        willSet(newValue) {
            textField.maxLength = newValue
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
        label.font = .bold(size: 14)
        label.textColor = .gray100
        return label
    }()
    
    private let requiredDot: UIView = {
        let view = UIView()
        view.backgroundColor = .pink
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pink
        label.font = .bold(size: 12)
        return label
    }()
    
    let textField: TextField
    
    init(
        title: String,
        isRequired: Bool = false,
        description: String? = nil,
        placeholder: String? = nil
    ) {
        self.textField = TextField(placeholder: placeholder)
        super.init(frame: .zero)
        
        self.titleLabel.text = title
        self.requiredDot.isHidden = !isRequired
        self.descriptionLabel.text = description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([
            titleLabel,
            requiredDot,
            descriptionLabel,
            textField
        ])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(24)
        }
        
        requiredDot.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.left.equalTo(titleLabel.snp.right).offset(4)
            $0.size.equalTo(4)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalToSuperview().offset(-24)
        }
        
        textField.snp.makeConstraints {
            $0.left.equalTo(titleLabel)
            $0.right.equalTo(descriptionLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        snp.makeConstraints { make in
            make.bottom.equalTo(textField).priority(.high)
        }
    }
    
    func setText(text: String?) {
        textField.setText(text: text)
    }
}

extension Reactive where Base: InputField {
    var text: ControlProperty<String> {
        return base.textField.rx.text
    }
}
