import UIKit

final class StatisticsView: BaseView {
    let refreshControl = UIRefreshControl()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .gray0
        return scrollView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    let favoriteCountLabel = FavoriteCountLabel()
    
    let dividerView = DividerView()
    
    let reviewCountLabel = ReviewCountLabel()
    
    let filterButton = StatisticsFilterButton()
    
    let containerView = UIView()
    
    override func setup() {
        scrollView.refreshControl = refreshControl
        setupLayout()
    }
    
    private func setupLayout() {
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(favoriteCountLabel)
        stackView.setCustomSpacing(24, after: favoriteCountLabel)
        
        stackView.addArrangedSubview(dividerView)
        stackView.setCustomSpacing(24, after: dividerView)
        
        stackView.addArrangedSubview(reviewCountLabel)
        stackView.setCustomSpacing(19, after: reviewCountLabel)
        
        stackView.addArrangedSubview(filterButton)
        stackView.setCustomSpacing(28, after: filterButton)
        
        stackView.addArrangedSubview(containerView)
        containerView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
        }
    }
    
    func updateContainerHeight(_ height: CGFloat) {
        containerView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }
}
