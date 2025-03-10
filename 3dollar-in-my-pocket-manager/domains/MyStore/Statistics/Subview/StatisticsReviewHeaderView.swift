import UIKit

final class StatisticsReviewHeaderView: UICollectionReusableView {
    enum Layout {
        static let height: CGFloat = 48
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 16)
        label.textColor = .gray95
        label.text = Strings.Statistics.Review.Header.title
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 16)
        label.textColor = .green
        return label
    }()
    
    private let ratingView = RatingView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(countLabel)
        addSubview(ratingView)
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        countLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
        }
        
        ratingView.snp.makeConstraints {
            $0.leading.equalTo(countLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(countLabel)
        }
    }
    
    func bind(count: Int, rating: Double) {
        countLabel.text = Strings.Statistics.Review.Header.countFormat(count)
        ratingView.bind(rating: rating)
    }
}
