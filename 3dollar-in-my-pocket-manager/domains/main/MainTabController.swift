import UIKit

import RxSwift

final class MainTabController: UITabBarController {
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let disposeBag = DisposeBag()
    
    static func instance() -> MainTabController {
        return MainTabController(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTabBarController()
        self.feedbackGenerator.prepare()
        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.feedbackGenerator.selectionChanged()
        
        guard let tabBarTag = TabBarTag(rawValue: item.tag) else { return }
        
        switch tabBarTag {
        case .home, .myPage:
            if #available(iOS 15, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                self.tabBar.standardAppearance = appearance
                self.tabBar.scrollEdgeAppearance = appearance
            } else {
                self.tabBar.barTintColor = .white
                self.tabBar.backgroundColor = .white
            }
            
        case .setting:
            if #available(iOS 15, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .gray100
                self.tabBar.standardAppearance = appearance
                self.tabBar.scrollEdgeAppearance = appearance
            } else {
                self.tabBar.barTintColor = .gray100
                self.tabBar.backgroundColor = .gray100
            }
        }
    }
    
    private func setupTabBarController() {
        self.setViewControllers([
            HomeViewController.instance(),
            HomeViewController.instance(),
            MyPageViewController.instance()
        ], animated: true)
        self.tabBar.tintColor = .green
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = UIColor.gray5.cgColor
        self.tabBar.barTintColor = .white
        self.tabBar.backgroundColor = .white
    }
}
