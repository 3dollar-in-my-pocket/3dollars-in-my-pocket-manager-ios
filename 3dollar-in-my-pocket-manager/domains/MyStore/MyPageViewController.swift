import UIKit

final class MyPageViewController: BaseViewController {
    private let myPageView = MyPageView()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private lazy var pageViewControllers: [UIViewController] = [
        createMyStoreInfoViewController(),
        createStatisticsViewController(),
        StorePostViewController()
    ]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    static func instance() -> UINavigationController {
        let viewController = MyPageViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_truck"),
                tag: TabBarTag.myPage.rawValue
            )
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override func loadView() {
        self.view = myPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPageViewController()
        setNoticeNewBadgeIfNeeded()
    }
    
    override func bindEvent() {
        self.myPageView.rx.tapTab
            .asDriver()
            .do(onNext: { [weak self] index in
                self?.sendAnalyticsEvent(selectedIndex: index)
            })
            .drive(onNext: { [weak self] index in
                guard let self = self else { return }
                self.pageViewController.setViewControllers(
                    [self.pageViewControllers[index]],
                    direction: .forward,
                    animated: false,
                    completion: nil
                )
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    private func setupPageViewController() {
        self.addChild(self.pageViewController)
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.myPageView.containerView.addSubview(self.pageViewController.view)
        self.pageViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(self.myPageView.containerView)
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
    
    private func sendAnalyticsEvent(selectedIndex: Int) {
        if selectedIndex == 0 {
            LogManager.shared.sendEvent(.init(
                screen: .myStoreInfo,
                eventName: .tapMyTopTab,
                extraParameters: [.tab: "myStoreInfo"]
            ))
        } else if selectedIndex == 1 {
            LogManager.shared.sendEvent(.init(
                screen: .myStoreInfo,
                eventName: .tapMyTopTab,
                extraParameters: [.tab: "statistics"]
            ))
        } else {
            LogManager.shared.sendEvent(.init(
                screen: .myStoreInfo,
                eventName: .tapMyTopTab,
                extraParameters: [.tab: "storePost"]
            ))
        }
    }
    
    private func setNoticeNewBadgeIfNeeded() {
        var userDefaults = Preference.shared
        let isShownStoreNoticeNewBadge = userDefaults.shownStoreNoticeNewBadge
        
        myPageView.storeNoticeButton.isNew = isShownStoreNoticeNewBadge.isNot
        if isShownStoreNoticeNewBadge.isNot {
            userDefaults.shownStoreNoticeNewBadge = true
        }
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
