import UIKit

import Base
import ReactorKit

final class StatisticsViewController: BaseViewController, View {
    private let statisticsView = StatisticsView()
    private let statisticsReactor = StatisticsReactor(globalState: GlobalState.shared)
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    private let totalStatisticsViewController = TotalStatisticsViewController.instance()
    private let dailyStatisticsViewController = DailyStatisticsViewController.instance()
    private var pageViewControllers: [UIViewController] = []
    private var isRefreshing = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    static func instance() -> StatisticsViewController {
        return StatisticsViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.statisticsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPageViewController()
        self.statisticsView.scrollView.delegate = self
        self.reactor = self.statisticsReactor
    }
    
    override func bindEvent() {
        self.statisticsView.rx.pullToRefresh
            .bind(onNext: { [weak self] in
                self?.isRefreshing = true
            })
            .disposed(by: self.eventDisposeBag)
        
        self.statisticsReactor.refreshPublisher
            .asDriver(onErrorJustReturn: .total)
            .drive(onNext: { [weak self] filterType in
                switch filterType {
                case .total:
                    self?.totalStatisticsViewController.refreshData()
                    
                case .day:
                    self?.dailyStatisticsViewController.refreshData()
                }
                self?.statisticsView.rx.endRefreshing.onNext(())
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: StatisticsReactor) {
        // BindAction
        self.statisticsView.filterButton.rx.tap
            .map { Reactor.Action.tapFilterButton($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.totalReviewCount }
            .asDriver(onErrorJustReturn: 0)
            .distinctUntilChanged()
            .drive(self.statisticsView.reviewCountLabel.rx.reviewCount)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.selectedFilter }
            .asDriver(onErrorJustReturn: .total)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] filterType in
                self?.setPage(filterType: filterType)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupPageViewController() {
        self.pageViewControllers = [
            self.totalStatisticsViewController,
            self.dailyStatisticsViewController
        ]
        self.addChild(self.pageViewController)
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.statisticsView.containerView.addSubview(self.pageViewController.view)
        self.pageViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(self.statisticsView.containerView)
        }
        self.pageViewController.setViewControllers(
            [self.pageViewControllers[0]],
            direction: .forward,
            animated: false,
            completion: nil
        )
        
        for view in self.pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    private func setPage(filterType: StatisticsFilterButton.FilterType) {
        switch filterType {
        case .total:
            self.pageViewController.setViewControllers(
                [self.pageViewControllers[0]],
                direction: .forward,
                animated: false,
                completion: nil
            )
            
        case .day:
            self.pageViewController.setViewControllers(
                [self.pageViewControllers[1]],
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
    }
}

extension StatisticsViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }
}

extension StatisticsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.isRefreshing {
            self.statisticsReactor.action.onNext(.refresh)
            self.isRefreshing = false
        }
    }
}
