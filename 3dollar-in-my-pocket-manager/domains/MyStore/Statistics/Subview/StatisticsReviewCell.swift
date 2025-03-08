import UIKit

final class StatisticsReviewCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 300
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let reviewItemView = ReviewItemView()
    
    private let commentView = CommentView()
    
    private var viewModel: ReviewItemViewModel?
    
    override func setup() {
        contentView.backgroundColor = .white
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(reviewItemView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reviewItemView.prepareForReuse()
        
        if commentView.superview.isNotNil {
            commentView.removeFromSuperview()
        }
    }
    
    func bind(viewModel: ReviewItemViewModel) {
        self.viewModel = viewModel
        reviewItemView.bind(viewModel: viewModel)
        
        if let comment = viewModel.output.review.comments.contents.first(where: { $0.isOwner }) {
            stackView.setCustomSpacing(-8, after: reviewItemView)
            stackView.addArrangedSubview(commentView)
            commentView.bind(comment: comment)
        } else {
            stackView.setCustomSpacing(20, after: reviewItemView)
        }
    }
}
