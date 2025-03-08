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
        super.prepareForReuse()
        
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
            stackView.setCustomSpacing(-8, after: reviewItemView)
            stackView.addArrangedSubview(commentView)
            commentView.bind(comment: comment)
        } else {
            stackView.setCustomSpacing(20, after: reviewItemView)
        }
    }
}
