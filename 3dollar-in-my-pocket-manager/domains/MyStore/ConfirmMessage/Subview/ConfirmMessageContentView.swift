import UIKit

final class ConfirmMessageContentView: BaseView {
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.layoutMargins = .init(top: 10, left: 16, bottom: 10, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        return stackView
    }()
    
    private let emojiView: UILabel = {
        let label = UILabel()
        label.text = "💌"
        label.font = .regular(size: 14)
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray95
        label.font = .semiBold(size: 14)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setLineHeight(lineHeight: 20)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray95
        label.font = .regular(size: 14)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setLineHeight(lineHeight: 20)
        return label
    }()
    
    override func setup() {
        setupUI()
    }
    
    func bind(storeName: String, message: String) {
        titleLabel.text = Strings.MessageConfirm.Content.titleFormat(storeName)
        titleLabel.setLineHeight(lineHeight: 20)
        messageLabel.text = message
        messageLabel.setLineHeight(lineHeight: 20)
    }
    
    private func setupUI() {
        backgroundColor = .gray10
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(emojiView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(messageLabel)
        
        emojiView.snp.makeConstraints {
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        
        horizontalStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(horizontalStackView)
        }
    }
}
