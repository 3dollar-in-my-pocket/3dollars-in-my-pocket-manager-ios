import UIKit

final class StatisticsViewController: BaseViewController {
    private let statisticsView = StatisticsView()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private let pageViewControllers: [UIViewController] = [
        TotalStatisticsViewController.instance(),
        TotalStatisticsViewController.instance()
    ]
    
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
    }
    
    private func setupPageViewController() {
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

