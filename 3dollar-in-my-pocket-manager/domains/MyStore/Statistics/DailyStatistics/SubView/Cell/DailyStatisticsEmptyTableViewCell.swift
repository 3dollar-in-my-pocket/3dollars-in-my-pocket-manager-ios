import UIKit

final class DailyStatisticsEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 68)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "🥲"
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 정보가 없어요"
        label.textColor = .gray95
        label.font = .bold(size: 14)
        return label
    }()
    
    private let countLabel: PaddingLabel = {
        let label = PaddingLabel(
            topInset: 4,
            bottomInset: 4,
            leftInset: 8,
            rightInset: 8
        )
        label.layer.cornerRadius = 13
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.gray30.cgColor
        label.text = "0개"
        label.textColor = .gray30
        label.font = .regular(size: 12)
        return label
    }()
    
    override func setup() {
        backgroundColor = .clear
        setupLayout()
        
    }
    
    private func setupLayout() {
        addSubViews([
            containerView,
            emojiLabel,
            messageLabel,
            countLabel
        ])
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
        
        emojiLabel.snp.makeConstraints {
            $0.centerY.equalTo(containerView)
            $0.leading.equalTo(containerView).offset(16)
        }
        
        messageLabel.snp.makeConstraints {
            $0.centerY.equalTo(emojiLabel)
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(8)
        }
        
        countLabel.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-16)
            $0.top.equalTo(containerView).offset(21)
            $0.bottom.equalTo(containerView).offset(-21)
            $0.height.equalTo(26)
        }
    }
}
