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
    }()CategorySelectView
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pink
        label.font = .bold(size: 12)
        return label
    }()
    
    fileprivate let textField: TextField
    
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
        addSubViews([
            titleLabel,
            requiredDot,
            descriptionLabel,
            textField
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        requiredDot.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.width.height.equalTo(4)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
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
