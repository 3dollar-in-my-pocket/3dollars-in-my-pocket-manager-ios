import UIKit

import RxSwift
import RxCocoa

final class StatisticsView: BaseView {
    fileprivate let refreshControl = UIRefreshControl()
    
    let scrollView = UIScrollView().then {
        $0.backgroundColor = .gray0
    }
    
    private let scrollViewContainerView = UIView()
    
    let reviewCountLabel = ReviewCountLabel()
    
    let filterButton = StatisticsFilterButton()
    
    let containerView = UIView()
    
    override func setup() {
        self.scrollView.refreshControl = self.refreshControl
        self.scrollViewContainerView.addSubViews([
            self.reviewCountLabel,
            self.filterButton,
            self.containerView
        ])
        self.scrollView.addSubview(self.scrollViewContainerView)
        self.addSubview(self.scrollView)
    }
    
    override func bindConstraints() {
        self.scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.scrollViewContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(self.reviewCountLabel).offset(-20).priority(.high)
            make.bottom.equalTo(self.containerView).priority(.high)
        }
        
        self.reviewCountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(20)
        }
        
        self.filterButton.snp.makeConstraints { make in
            make.top.equalTo(self.reviewCountLabel.snp.bottom).offset(19)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.filterButton.snp.bottom).offset(28)
            make.height.equalTo(0)
        }
    }
    
    func updateContainerViewHeight(tableViewHeight: CGFloat) {
        self.containerView.snp.updateConstraints { make in
            make.height.equalTo(tableViewHeight)
        }
    }
}

extension Reactive where Base: StatisticsView {
    var pullToRefresh: ControlEvent<Void> {
        return ControlEvent(events: base.refreshControl.rx.controlEvent(.valueChanged)
            .map { _ in () })
    }
    
    var endRefreshing: Binder<Void> {
        return Binder(self.base) { view, _ in
            view.refreshControl.endRefreshing()
        }
    }
}
