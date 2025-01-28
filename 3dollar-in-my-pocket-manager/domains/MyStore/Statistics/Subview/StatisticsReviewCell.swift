import UIKit

final class StatisticsReviewCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 300
        static let imageHeight: CGFloat = 96
        static func calculateHeight(review: StoreReviewResponse) -> CGFloat {
            let imageHeight = review.images.isEmpty ? 0 : imageHeight
            return 104 + imageHeight + reviewHeight(review: review.contents)
        }
        
        static func reviewHeight(review: String?) -> CGFloat {
            guard let review else { return .zero }
            let constraintRect = CGSize(
                width: UIUtils.windowBounds.width - 48,
                height: .greatestFiniteMagnitude
            )
            let height = review.boundingRect(
                with: constraintRect,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: UIFont.regular(size: 14) as Any],
                context: nil
            ).height
            
            return height
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray80
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray40
        return label
    }()
    
    private let titleBadgeView = TitleBadgeView()
    
    private let starBadgeView = StarBadgeView()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.contentInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([
            ImageItemCell.self,
            BaseCollectionViewCell.self
        ])
        return collectionView
    }()
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = ImageItemCell.Layout.size
        return layout
    }
    
    private let reviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray80
        label.font = .regular(size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private var viewModel: StatisticsReviewCellViewModel?
    
    override func setup() {
        contentView.backgroundColor = .white
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleBadgeView)
        contentView.addSubview(starBadgeView)
        contentView.addSubview(collectionView)
        contentView.addSubview(reviewLabel)
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(dateLabel).offset(-12)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        titleBadgeView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
        }
        
        starBadgeView.snp.makeConstraints {
            $0.centerY.equalTo(titleBadgeView)
            $0.leading.equalTo(titleBadgeView.snp.trailing).offset(4)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(titleBadgeView.snp.bottom).offset(12)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(ImageItemCell.Layout.size.height)
        }
        
        reviewLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(collectionView.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func bind(viewModel: StatisticsReviewCellViewModel) {
        self.viewModel = viewModel
        
        let review = viewModel.output.review
        nameLabel.text = review.writer.name
        dateLabel.text = DateUtils.toString(dateString: review.createdAt, format: "yyyy.MM.dd")
        titleBadgeView.bind(medal: review.writer.medal)
        starBadgeView.bind(rating: review.rating)
        collectionView.reloadData()
        reviewLabel.text = review.contents
        
        collectionView.snp.updateConstraints {
            $0.height.equalTo(review.images.isEmpty ? 0 : ImageItemCell.Layout.size.height)
        }
    }
}

extension StatisticsReviewCell {
    final class ImageItemCell: BaseCollectionViewCell {
        enum Layout {
            static let size = CGSize(width: 96, height: 96)
        }
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = 8
            imageView.layer.masksToBounds = true
            return imageView
        }()
        
        override func setup() {
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        func bind(_ imageUrl: String) {
            imageView.setImage(urlString: imageUrl)
        }
    }
}

extension StatisticsReviewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.review.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageUrl = viewModel?.output.review.images[safe: indexPath.item]?.imageUrl else { return UICollectionViewCell() }
        let cell: ImageItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(imageUrl)
        return cell
    }
}

extension StatisticsReviewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didTapPhoto.send(indexPath.item)
    }
}
