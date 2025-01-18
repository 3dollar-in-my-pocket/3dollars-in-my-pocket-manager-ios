import UIKit
import CombineCocoa

final class FeedbackDetailViewController: BaseViewController {
    private let refreshControl = UIRefreshControl()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .gray0
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let reviewCountLabel = ReviewCountLabel()
    
    private let filterButton = StatisticsFilterButton()
    
    private let containerView = UIView()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    private var pageViewControllers: [UIViewController] = []
    
    private let viewModel: FeedbackDetailViewModel
    private var totalStatisticsViewController: TotalStatisticsViewController?
    private var dailyStatisticsViewController: DailyStatisticsViewController?
    
    private var isRefreshing = false
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    init(viewModel: FeedbackDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
        scrollView.delegate = self
        viewModel.input.viewDidLoad.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(r: 251, g: 251, b: 251)
        addNavigationBar()
        title = Strings.FeedbackDetail.title
        
        scrollView.refreshControl = refreshControl
        
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(reviewCountLabel)
        stackView.setCustomSpacing(19, after: reviewCountLabel)
        
        stackView.addArrangedSubview(filterButton)
        stackView.setCustomSpacing(28, after: filterButton)
        
        stackView.addArrangedSubview(containerView)
        containerView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        view.addSubview(scrollView)
        
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
    
    private func bind() {
        // Input
        refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: FeedbackDetailViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        filterButton.tapPublisher
            .removeDuplicates()
            .subscribe(viewModel.input.didTapFilter)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.totalReviewCount
            .main
            .withUnretained(self)
            .sink { (owner: FeedbackDetailViewController, reviewCount: Int) in
                owner.reviewCountLabel.bind(reviewCount)
            }
            .store(in: &cancellables)
        
        viewModel.output.setPageViewController
            .main
            .withUnretained(self)
            .sink { (owner: FeedbackDetailViewController, viewModels) in
                let (totalStatisticsViewModel, dailyStatisticsViewModel) = viewModels
                let selectedFilter = owner.viewModel.output.filter.value
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
            .sink { (owner: FeedbackDetailViewController, filterType: StatisticsFilterButton.FilterType) in
                owner.setPage(filterType: filterType)
            }
            .store(in: &cancellables)
        
        viewModel.output.updateContainerHeight
            .main
            .withUnretained(self)
            .sink { (owner: FeedbackDetailViewController, height: CGFloat) in
                owner.updateContainerHeight(height)
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
            containerView.addSubview(pageViewController.view)
            pageViewController.view.snp.makeConstraints {
                $0.edges.equalTo(containerView)
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
    
    private func updateContainerHeight(_ height: CGFloat) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            containerView.snp.updateConstraints {
                $0.height.equalTo(height)
            }
        }
    }
}

extension FeedbackDetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
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

extension FeedbackDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isRefreshing {
            viewModel.input.refresh.send(())
            isRefreshing = false
            refreshControl.endRefreshing()
        }
    }
}
