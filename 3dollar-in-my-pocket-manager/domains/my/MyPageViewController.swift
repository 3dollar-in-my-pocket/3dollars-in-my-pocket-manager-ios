import UIKit

final class MyPageViewController: BaseViewController {
    private let myPageView = MyPageView()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .pageCurl,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private let pageViewControllers: [BaseViewController] = [
        MyStoreInfoViewController.instance(),
        MyStoreInfoViewController.instance()
    ]
    
    static func instance() -> MyPageViewController {
        return MyPageViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_home"),
                tag: TabBarTag.myPage.rawValue
            )
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
    }
    
    override func loadView() {
        self.view = myPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPageViewController()
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
    }
}

extension MyPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? BaseViewController,
              let index = self.pageViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = index - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard self.pageViewControllers.count > previousIndex else {
            return nil
        }
        
        return self.pageViewControllers[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? BaseViewController,
              let index = self.pageViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = index + 1
        
        guard nextIndex < self.pageViewControllers.count else {
            return nil
        }
        
        guard self.pageViewControllers.count > nextIndex else {
            return nil
        }
        
        return self.pageViewControllers[nextIndex]
    }
}
