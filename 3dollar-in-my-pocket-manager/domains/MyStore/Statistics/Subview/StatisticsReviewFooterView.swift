import UIKit
import Combine

final class StatisticsReviewFooterView: UICollectionReusableView {
    enum Layout {
        static let height: CGFloat = 72
    }
    
    let totalReviewButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = Strings.Statistics.Review.totalReview
        config.attributedTitle = AttributedString(
            Strings.Statistics.Review.totalReview, attributes: .init([
                .font: UIFont.semiBold(size: 14) as Any,
                .foregroundColor: UIColor.white
            ])
        )
        let button = UIButton(configuration: config)
        button.backgroundColor = .green
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
    
    private func setup() {
        backgroundColor = .white
        addSubview(totalReviewButton)
        totalReviewButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(48)
        }
    }
}
