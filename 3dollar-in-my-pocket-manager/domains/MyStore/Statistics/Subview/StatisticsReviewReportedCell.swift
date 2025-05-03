import UIKit

final class StatisticsReviewReportedCell: BaseCollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray80
        label.font = .medium(size: 12)
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray40
        return label
    }()
    
    private let reportedLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        label.text = Strings.Statistics.Review.reported
        return label
    }()
    
    override func setup() {
        contentView.backgroundColor = .white
        contentView.addSubViews([
            titleLabel,
            dateLabel,
            reportedLabel
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-60)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        reportedLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(dateLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func bind(_ review: StoreReviewResponse) {
        titleLabel.text = review.writer.name
        dateLabel.text = DateUtils.toString(dateString: review.createdAt, format: "yyyy.MM.dd")
    }
}
