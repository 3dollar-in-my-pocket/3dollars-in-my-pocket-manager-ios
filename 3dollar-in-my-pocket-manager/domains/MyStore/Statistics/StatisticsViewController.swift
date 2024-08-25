import UIKit

import CombineCocoa

final class StatisticsViewController: BaseViewController {
    private let viewModel: StatisticsViewModel
    private let statisticsView = StatisticsView()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    private var pageViewControllers: [UIViewController] = []
    
    private var totalStatisticsViewController: TotalStatisticsViewController?
    private var dailyStatisticsViewController: DailyStatisticsViewController?
    
    private var isRefreshing = false
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func loadView() {
        view = statisticsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        statisticsView.scrollView.delegate = self
        viewModel.input.viewDidLoad.send(())
    }
    
    private func bind() {
        // Input
        statisticsView.refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        statisticsView.filterButton.tapPublisher
            .removeDuplicates()
            .subscribe(viewModel.input.didTapFilter)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.subscriberCount
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, subscriberCount: Int) in
                owner.statisticsView.favoriteCountLabel.bind(subscriberCount)
            }
            .store(in: &cancellables)
        
        viewModel.output.totalReviewCount
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, reviewCount: Int) in
                owner.statisticsView.reviewCountLabel.bind(reviewCount)
            }
            .store(in: &cancellables)
        
        viewModel.output.setPageViewController
            .combineLatest(viewModel.output.filter)
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, viewModels) in
                let ((totalStatisticsViewModel, dailyStatisticsViewModel), selectedFilter) = viewModels
                owner.setupPageViewController(
                    totalStatisticsViewModel: totalStatisticsViewModel,
                    dailyStatisticsViewModel: dailyStatisticsViewModel,
                    selectedFilter: selectedFilter
                )
            }
            .store(in: &cancellables)
        
        viewModel.output.filter
            .dropFirst()
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, filterType: StatisticsFilterButton.FilterType) in
                owner.setPage(filterType: filterType)
            }
            .store(in: &cancellables)
        
        viewModel.output.updateContainerHeight
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, height: CGFloat) in
                owner.statisticsView.updateContainerHeight(height)
            }
            .store(in: &cancellables)
    }
    
    private func setupPageViewController(
        totalStatisticsViewModel: TotalStatisticsViewModel,
        dailyStatisticsViewModel: DailyStatisticsViewModel,
        selectedFilter: StatisticsFilterButton.FilterType
    ) {
        let totalStatisticsViewController = TotalStatisticsViewController(viewModel: totalStatisticsViewModel)
        self.totalStatisticsViewController = totalStatisticsViewController
        
        let dailyStatisticsViewController = DailyStatisticsViewController(viewModel: dailyStatisticsViewModel)
        self.dailyStatisticsViewController = dailyStatisticsViewController
        
        pageViewControllers.removeAll()
        pageViewControllers = [
            totalStatisticsViewController,
            dailyStatisticsViewController
        ]
        if pageViewController.parent.isNil {
            addChild(pageViewController)
            statisticsView.containerView.addSubview(pageViewController.view)
            pageViewController.view.snp.makeConstraints {
                $0.edges.equalTo(statisticsView.containerView)
            }
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        var selectedViewController: UIViewController
        switch selectedFilter {
        case .total:
            selectedViewController = totalStatisticsViewController
        case .day:
            selectedViewController = dailyStatisticsViewController
        }
        
        pageViewController.setViewControllers(
            [selectedViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
    
    private func setPage(filterType: StatisticsFilterButton.FilterType) {
        switch filterType {
        case .total:
            pageViewController.setViewControllers(
                [pageViewControllers[0]],
                direction: .forward,
                animated: false,
                completion: nil
            )
            
        case .day:
            pageViewController.setViewControllers(
                [pageViewControllers[1]],
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
        if isRefreshing {
            viewModel.input.refresh.send(())
            isRefreshing = false
            statisticsView.refreshControl.endRefreshing()
        }
    }
}
