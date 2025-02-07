import UIKit

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
