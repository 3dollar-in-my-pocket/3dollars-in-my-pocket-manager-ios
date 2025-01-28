import Foundation
import UIKit

final class StatisticsReviewEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 146
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.imgEmptyReview.image
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray40
        label.text = Strings.Statistics.Review.Empty.title
        return label
    }()
    
    override func setup() {
        contentView.backgroundColor = .white
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(emptyImageView)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
