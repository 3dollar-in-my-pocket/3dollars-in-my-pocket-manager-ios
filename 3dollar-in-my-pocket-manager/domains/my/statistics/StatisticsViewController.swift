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
    private let dailyStatisticsViewController = DailyStatisticsViewController.instance()
    
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
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, viewModels: (TotalStatisticsViewModel)) in
                owner.setupPageViewController(totalStatisticsViewModel: viewModels)
            }
            .store(in: &cancellables)
        
        viewModel.output.filter
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
    
//    override func bindEvent() {
//        
        // TODO: 뷰모델에서 처리할 수 있을듯?
//        self.statisticsReactor.refreshPublisher
//            .asDriver(onErrorJustReturn: .total)
//            .drive(onNext: { [weak self] filterType in
//                switch filterType {
//                case .total:
//                    self?.totalStatisticsViewController.refreshData()
//                    
//                case .day:
//                    self?.dailyStatisticsViewController.refreshData()
//                }
//                self?.statisticsView.rx.endRefreshing.onNext(())
//            })
//            .disposed(by: self.eventDisposeBag)
//    }
    
    private func setupPageViewController(
        totalStatisticsViewModel: TotalStatisticsViewModel
    ) {
        let totalStatisticsViewController = TotalStatisticsViewController(viewModel: totalStatisticsViewModel)
        self.totalStatisticsViewController = totalStatisticsViewController
        
        pageViewControllers.removeAll()
        pageViewControllers = [
            totalStatisticsViewController
        ]
        addChild(pageViewController)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        statisticsView.containerView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.edges.equalTo(statisticsView.containerView)
        }
        pageViewController.setViewControllers(
            [totalStatisticsViewController],
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
