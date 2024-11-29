import UIKit

final class MyPageViewController: BaseViewController {
    private let subTabView = MyPageSubTabView()
    
    private let containerView = UIView()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private var tooltipView: TooltipView?

    private let viewModel: MyPageViewModel
    private lazy var pageViewControllers: [UIViewController] = [
        createMyStoreInfoViewController(),
        createStatisticsViewController(),
        StorePostViewController(),
        MessageViewController(viewModel: MessageViewModel())
    ]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: nil, image: Assets.icTruck.image, tag: TabBarTag.myPage.rawValue)
        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupPageViewController()
        bind()
        
        viewModel.input.load.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.willAppear.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = .gray0
        view.addSubview(subTabView)
        view.addSubview(containerView)
        
        subTabView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(subTabView.snp.bottom)
        }
    }
    
    private func setupPageViewController() {
        addChild(pageViewController)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        containerView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
        pageViewController.setViewControllers(
            [pageViewControllers[0]],
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
    
    private func bind() {
        // Input
        subTabView.didTapPublisher
            .subscribe(viewModel.input.didTapSubTab)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.showNewBadge
            .main
            .withUnretained(self)
            .sink { (owner: MyPageViewController, _) in
                owner.subTabView.messageButton.isNew = true
            }
            .store(in: &cancellables)
        
        viewModel.output.pageViewControllerIndex
            .main
            .withUnretained(self)
            .sink { (owner: MyPageViewController, selectedIndex: Int) in
                let selectedViewController = owner.pageViewControllers[selectedIndex]
                owner.pageViewController.setViewControllers([selectedViewController], direction: .forward, animated: false)
            }
            .store(in: &cancellables)
        
        viewModel.output.showMessageTooptip
            .removeDuplicates()
            .main
            .withUnretained(self)
            .sink { (owner: MyPageViewController, isShow: Bool) in
                if isShow {
                    owner.showMessageTooltip()
                } else {
                    owner.tooltipView?.removeFromSuperview()
                }
            }
            .store(in: &cancellables)
    }
    
    private func createMyStoreInfoViewController() -> UIViewController {
        let viewModel = MyStoreInfoViewModel()
        let viewController = MyStoreInfoViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
    
    private func createStatisticsViewController() -> UIViewController {
        let viewModel = StatisticsViewModel()
        let viewController = StatisticsViewController(viewModel: viewModel)
        
        return viewController
    }
    
    private func showMessageTooltip() {
        let tooltipView = TooltipView(emoji: "🙋", message: Strings.MyPage.Message.toolTip, tailDirection: .topRight)
        view.addSubview(tooltipView)
        tooltipView.snp.makeConstraints {
            $0.trailing.equalTo(subTabView.messageButton.snp.centerX).offset(26)
            $0.top.equalTo(subTabView.messageButton.snp.bottom).offset(4)
        }
        self.tooltipView = tooltipView
    }
}

extension MyPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
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
