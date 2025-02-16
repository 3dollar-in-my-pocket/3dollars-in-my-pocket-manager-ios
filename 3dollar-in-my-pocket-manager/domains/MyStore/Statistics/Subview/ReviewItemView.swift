import UIKit

final class ReviewItemView: BaseView {
    enum Layout {
        static func contentsHeight(text: String?) -> CGFloat {
            guard let text else { return .zero }
            let horizontalPadding: CGFloat = 24
            let constraintRect = CGSize(
                width: UIUtils.windowBounds.width - (horizontalPadding * 2),
                height: .greatestFiniteMagnitude
            )
            let height = text.boundingRect(
                with: constraintRect,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: UIFont.regular(size: 14) as Any],
                context: nil
            ).height
            
            return height
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 20, left: 0, bottom: 20, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let headerView = HeaderView()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.contentInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
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
    
    private let reviewLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 0, bottomInset: 0, leftInset: 24, rightInset: 24)
        label.textColor = .gray80
        label.font = .regular(size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let likeButton = LikeButton()
    
    private var viewModel: ReviewItemViewModel?
    
    override func setup() {
        backgroundColor = .white
        addSubview(stackView)
        
        stackView.addArrangedSubview(headerView)
        stackView.setCustomSpacing(12, after: headerView)
        headerView.snp.makeConstraints {
            $0.height.equalTo(HeaderView.Layout.height)
        }
        
        stackView.addArrangedSubview(reviewLabel)
        stackView.setCustomSpacing(12, after: reviewLabel)
        reviewLabel.snp.makeConstraints {
            $0.height.equalTo(0)
        }
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 0
        horizontalStackView.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
        horizontalStackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(likeButton)
        horizontalStackView.addArrangedSubview(UIView())
        horizontalStackView.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(viewModel: ReviewItemViewModel) {
        self.viewModel = viewModel
        
        let review = viewModel.output.review
        headerView.bind(review: review)
        
        if review.images.isNotEmpty {
            stackView.insertArrangedSubview(collectionView, at: 1)
            stackView.setCustomSpacing(12, after: collectionView)
            
            collectionView.snp.makeConstraints {
                $0.height.equalTo(ImageItemCell.Layout.size.height)
            }
            collectionView.reloadData()
        }
        
        if let sticker = review.stickers.first {
            likeButton.bind(isLiked: sticker.reactedByMe)
            likeButton.bind(count: sticker.count)
        }
        
        stackView.setCustomSpacing(12, after: likeButton)
        
        reviewLabel.text = review.contents
        reviewLabel.snp.updateConstraints {
            $0.height.equalTo(Layout.contentsHeight(text: review.contents))
        }
        
        // Input
        likeButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapHeart)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.likedByMe
            .main
            .withUnretained(self)
            .sink { (owner: ReviewItemView, likedByMe: Bool) in
                owner.likeButton.bind(isLiked: likedByMe)
            }
            .store(in: &cancellables)
            
        viewModel.output.likedCount
            .main
            .withUnretained(self)
            .sink { (owner: ReviewItemView, likeCount: Int) in
                owner.likeButton.bind(count: likeCount)
            }
            .store(in: &cancellables)
    }
    
    func prepareForReuse() {
        if collectionView.superview.isNotNil {
            collectionView.removeFromSuperview()
        }
    }
}

extension ReviewItemView {
    final class HeaderView: BaseView {
        enum Layout {
            static let height: CGFloat = 40
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
        
        override func setup() {
            addSubViews([
                nameLabel,
                dateLabel,
                titleBadgeView,
                starBadgeView
            ])
            
            nameLabel.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(24)
                $0.top.equalToSuperview()
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
        }
        
        func bind(review: StoreReviewResponse) {
            nameLabel.text = review.writer.name
            dateLabel.text = DateUtils.toString(dateString: review.createdAt, format: "yyyy.MM.dd")
            titleBadgeView.bind(medal: review.writer.medal)
            starBadgeView.bind(rating: review.rating)
        }
    }
    
    final class ImageItemCell: BaseCollectionViewCell {
        enum Layout {
            static let size = CGSize(width: 96, height: 96)
        }
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = 8
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
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
    
    final class LikeButton: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            var config = UIButton.Configuration.plain()
            config.image = Assets.icHeartLine.image.resizeImage(scaledTo: 16).withRenderingMode(.alwaysTemplate)
            config.contentInsets = .zero
            config.attributedTitle = AttributedString(Strings.ReviewList.like, attributes: .init([
                .font: UIFont.medium(size: 10) as Any,
                .foregroundColor: UIColor.gray60
            ]))
            self.configuration = config
            tintColor = .clear
        }
        
        func bind(count: Int) {
            let text = Strings.ReviewList.likeCountFormat(count)
            configuration?.attributedTitle = AttributedString(text, attributes: .init([
                .font: UIFont.medium(size: 10) as Any,
                .foregroundColor: UIColor.gray60
            ]))
        }
        
        func bind(isLiked: Bool) {
            let tintColor: UIColor = isLiked ? .red : .gray60
            configuration?.image = isLiked ? Assets.icHeartFill.image.resizeImage(scaledTo: 16).withTintColor(tintColor) : Assets.icHeartLine.image.resizeImage(scaledTo: 16).withTintColor(tintColor)
            
            if var attributedTitle = configuration?.attributedTitle {
                attributedTitle.foregroundColor = isLiked ? UIColor.red : UIColor.gray60
                configuration?.attributedTitle = attributedTitle
            }
            
            isSelected = isLiked
        }
    }
}

extension ReviewItemView: UICollectionViewDataSource {
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

extension ReviewItemView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didTapPhoto.send(indexPath.item)
    }
}
