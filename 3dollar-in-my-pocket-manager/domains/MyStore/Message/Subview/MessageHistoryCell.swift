import UIKit

final class MessageHistoryCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 100
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .gray5
        stackView.layer.cornerRadius = 12
        stackView.layer.masksToBounds = true
        stackView.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray95
        label.font = .regular(size: 14)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray60
        return label
    }()
    
    override func setup() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(timeLabel)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
    
    func bind(message: StoreMessageResponse) {
        messageLabel.text = message.body
        messageLabel.setLineHeight(lineHeight: 20)
        
        let createdDate = DateUtils.toDate(dateString: message.createdAt)
        if createdDate.isToday() {
            timeLabel.text = DateUtils.toString(date: createdDate, format: "HH:mm")
        } else {
            timeLabel.text = DateUtils.toString(date: createdDate, format: "yyyy-MM-dd E")
        }
    }
}
