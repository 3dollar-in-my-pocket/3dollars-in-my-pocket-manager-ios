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

extension StatisticsReviewHeaderView {
    final class RatingView: BaseView {
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.backgroundColor = .green100
            stackView.layer.cornerRadius = 4
            stackView.layer.masksToBounds = true
            stackView.layoutMargins = .init(top: 2, left: 6, bottom: 2, right: 6)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.alignment = .center
            return stackView
        }()
        
        private let starImage: UIImageView = {
            let imageView = UIImageView()
            imageView.image = Assets.icStarSolid.image
                .resizeImage(scaledTo: 14)
                .withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .green
            return imageView
        }()
        
        private let ratingLabel: UILabel = {
            let label = UILabel()
            label.font = .medium(size: 12)
            label.textColor = .gray90
            return label
        }()
        
        override func setup() {
            addSubview(stackView)
            stackView.snp.makeConstraints {
                $0.height.equalTo(22)
            }
            
            stackView.addArrangedSubview(starImage)
            stackView.addArrangedSubview(ratingLabel)
            
            starImage.snp.makeConstraints {
                $0.size.equalTo(14).priority(.required)
            }
            snp.makeConstraints {
                $0.edges.equalTo(stackView)
            }
        }
        
        func bind(rating: Double) {
            ratingLabel.text = "\(rating)"
            ratingLabel.setLineHeight(lineHeight: 18)
        }
    }
}
