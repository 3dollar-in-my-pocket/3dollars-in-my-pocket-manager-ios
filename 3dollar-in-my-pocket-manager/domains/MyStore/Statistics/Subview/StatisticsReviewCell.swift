import UIKit

final class StatisticsReviewCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 300
    }
    
    private let reviewItemView = ReviewItemView()
    
    private var viewModel: ReviewItemViewModel?
    
    override func setup() {
        contentView.backgroundColor = .white
        contentView.addSubview(reviewItemView)
        reviewItemView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(viewModel: ReviewItemViewModel) {
        self.viewModel = viewModel
        reviewItemView.bind(viewModel: viewModel)
    }
}
