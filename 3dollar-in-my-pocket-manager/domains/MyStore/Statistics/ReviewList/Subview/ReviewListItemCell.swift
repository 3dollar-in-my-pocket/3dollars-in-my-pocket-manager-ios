import UIKit
import Combine

final class ReviewListItemCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 300
        static let imageHeight: CGFloat = 96
        static func calculateHeight(review: StoreReviewResponse) -> CGFloat {
            var height: CGFloat = 0
            let headerHeight: CGFloat = 72 // (40 + 상단 간격 20 + 하단 간격 12)
            height += headerHeight
            
            if review.images.isNotEmpty {
                height += imageHeight
                height += 12 // 이미지 하단 간격 12
            }
            
            let reviewHeight = contentsHeight(text: review.contents, horizontalPadding: 24)
            height += reviewHeight
            
            let liveButtonHeight: CGFloat = 16
            height += liveButtonHeight
            
            if let comment = review.comments.contents.first {
                height += 12 // 댓글 상단 간격 12
                let commentHeight = contentsHeight(text: comment.content, horizontalPadding: 40)
                height += commentHeight
                height += 50 // 대댓글 내용 제외한 높이
            }
            
            height += 20 // 대댓글 없는 경우, 좋아요 버튼 하단 간격, 대댓글 있는 경우, 대댓글 하단 간격
            return height
        }
        
        static func contentsHeight(text: String?, horizontalPadding: CGFloat) -> CGFloat {
            guard let text else { return .zero }
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
    
    private let commentView = CommentView()
    
    private var viewModel: ReviewListItemCellViewModel?
    
    override func setup() {
        contentView.backgroundColor = .white
        contentView.addSubview(stackView)
        
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
        }
    }
    
    override func prepareForReuse() {
        if collectionView.superview.isNotNil {
            collectionView.removeFromSuperview()
        }
        
        if commentView.superview.isNotNil {
            commentView.removeFromSuperview()
        }
    }
    
    func bind(viewModel: ReviewListItemCellViewModel) {
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
        
        if let comment = review.comments.contents.first(where: { $0.isOwner }) {
            stackView.setCustomSpacing(12, after: likeButton)
            stackView.addArrangedSubview(commentView)
            commentView.bind(comment: comment)
        } else {
            stackView.setCustomSpacing(20, after: likeButton)
        }
        
        reviewLabel.text = review.contents
        reviewLabel.snp.updateConstraints {
            $0.height.equalTo(Layout.contentsHeight(text: review.contents, horizontalPadding: 24))
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
            .sink { (owner: ReviewListItemCell, likedByMe: Bool) in
                owner.likeButton.bind(isLiked: likedByMe)
            }
            .store(in: &cancellables)
            
        viewModel.output.likedCount
            .main
            .withUnretained(self)
            .sink { (owner: ReviewListItemCell, likeCount: Int) in
                owner.likeButton.bind(count: likeCount)
            }
            .store(in: &cancellables)
    }
    
}

extension ReviewListItemCell {
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
    
    final class CommentView: BaseView {
        private let containerView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 12
            view.layer.masksToBounds = true
            view.backgroundColor = .gray0
            return view
        }()
        
        private let nameLabel: UILabel = {
            let label = UILabel()
            label.font = .bold(size: 12)
            label.textColor = .gray80
            label.textAlignment = .left
            return label
        }()
        
        private let dateLabel: UILabel = {
            let label = UILabel()
            label.font = .medium(size: 12)
            label.textColor = .gray40
            return label
        }()
        
        private let contentLabel: UILabel = {
            let label = UILabel()
            label.font = .regular(size: 14)
            label.textColor = .gray80
            label.numberOfLines = 0
            return label
        }()
        
        override func setup() {
            addSubViews([
                containerView,
                nameLabel,
                dateLabel,
                contentLabel
            ])
            
            containerView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.equalToSuperview().offset(-24)
                $0.top.equalToSuperview()
                $0.bottom.equalTo(contentLabel).offset(12)
            }
            
            nameLabel.snp.makeConstraints {
                $0.leading.equalTo(containerView).offset(16)
                $0.top.equalTo(containerView).offset(12)
                $0.trailing.lessThanOrEqualTo(dateLabel).offset(-16)
            }
            
            dateLabel.snp.makeConstraints {
                $0.centerY.equalTo(nameLabel)
                $0.trailing.equalTo(containerView).offset(-16)
            }
            
            contentLabel.snp.makeConstraints {
                $0.leading.equalTo(containerView).offset(16)
                $0.top.equalTo(nameLabel.snp.bottom).offset(8)
                $0.trailing.equalTo(containerView).offset(-16)
            }
            
            snp.makeConstraints {
                $0.top.equalTo(containerView)
                $0.bottom.equalTo(containerView)
            }
        }
        
        func bind(comment: CommentResponse) {
//            nameLabel.text = comment.writer.name
            dateLabel.text = DateUtils.toString(dateString: comment.createdAt, format: "yyyy.MM.dd")
            contentLabel.text = comment.content
            contentLabel.setLineHeight(lineHeight: 20)
        }
    }
}

extension ReviewListItemCell: UICollectionViewDataSource {
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

extension ReviewListItemCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didTapPhoto.send(indexPath.item)
    }
}
