import UIKit

final class DailyStatisticsStackItemView: BaseView {
    enum Layout {
        static let height: CGFloat = 26
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray95
        return label
    }()
    
    private let countLabel: PaddingLabel = {
        let label = PaddingLabel(
            topInset: 4,
            bottomInset: 4,
            leftInset: 8,
            rightInset: 8
        )
        label.font = .regular(size: 12)
        label.textColor = .green
        label.layer.borderColor = UIColor.green.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 11
        return label
    }()
    
    override func setup() {
        backgroundColor = .clear
        
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([
            titleLabel,
            countLabel
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Layout.height)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(countLabel).priority(.high)
            $0.bottom.equalTo(countLabel).priority(.high)
            $0.height.equalTo(Layout.height)
        }
    }
    
    func bind(feedback: FeedbackCountResponse, feedbackType: FeedbackTypeResponse) {
        titleLabel.text = "\(feedbackType.emoji) \(feedbackType.description)"
        countLabel.text = "\(feedback.count)개"
    }
}
