import UIKit

import RxSwift

final class MainTabController: UITabBarController {
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let disposeBag = DisposeBag()
    private let borderLayer = CALayer()
    
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
        case .home:
            LogManager.shared.sendEvent(.init(
                screen: .mainTab,
                eventName: .tapBottomTab,
                extraParameters: [.tab: "home"]
            ))
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
            self.borderLayer.backgroundColor = UIColor.gray5.cgColor
            
        case .myPage:
            LogManager.shared.sendEvent(.init(
                screen: .mainTab,
                eventName: .tapBottomTab,
                extraParameters: [.tab: "my"]
            ))
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
            self.borderLayer.backgroundColor = UIColor.gray5.cgColor
            
        case .setting:
            LogManager.shared.sendEvent(.init(
                screen: .mainTab,
                eventName: .tapBottomTab,
                extraParameters: [.tab: "setting"]
            ))
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
            self.borderLayer.backgroundColor = UIColor.gray90.cgColor
        }
    }
    
    private func setupTabBarController() {
        self.setViewControllers([
            HomeViewController(),
            MyPageViewController.instance(),
            SettingViewController.instance()
        ], animated: true)
        
        self.borderLayer.backgroundColor = UIColor.gray5.cgColor
        self.borderLayer.frame = .init(x: 0, y: 0, width: self.tabBar.frame.size.width, height: 1)
        
        self.tabBar.tintColor = .green
        self.tabBar.barTintColor = .white
        self.tabBar.backgroundColor = .white
        self.tabBar.layer.addSublayer(self.borderLayer)
    }
}
