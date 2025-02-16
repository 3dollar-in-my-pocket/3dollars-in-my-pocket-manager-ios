import UIKit
import Combine

final class ReviewListItemCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 300
        static let imageHeight: CGFloat = 96
        static func calculateHeight(review: StoreReviewResponse) -> CGFloat {
            var height: CGFloat = 0
            let headerHeight: CGFloat = ReviewItemView.HeaderView.Layout.height + 32 // (상단 간격 20 + 하단 간격 12)
            height += headerHeight
            
            if review.images.isNotEmpty {
                height += imageHeight
                height += 12 // 이미지 하단 간격 12
            }
            
            let reviewHeight = contentsHeight(text: review.contents, horizontalPadding: 24)
            height += (reviewHeight + 12) // 리뷰 하단 간격 12
            
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
        return stackView
    }()
    
    private let reviewItemView = ReviewItemView()
    
    private let commentView = CommentView()
    
    private var viewModel: ReviewListItemCellViewModel?
    
    override func setup() {
        contentView.backgroundColor = .white
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(reviewItemView)
        stackView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        reviewItemView.prepareForReuse()
        
        if commentView.superview.isNotNil {
            commentView.removeFromSuperview()
        }
    }
    
    func bind(viewModel: ReviewListItemCellViewModel) {
        self.viewModel = viewModel
        reviewItemView.bind(viewModel: viewModel.reviewItemViewModel)
        let review = viewModel.output.review
        
        if let comment = review.comments.contents.first(where: { $0.isOwner }) {
            stackView.setCustomSpacing(12, after: reviewItemView)
            stackView.addArrangedSubview(commentView)
            commentView.bind(comment: comment)
        } else {
            stackView.setCustomSpacing(20, after: reviewItemView)
        }
    }
    
}

extension ReviewListItemCell {
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
