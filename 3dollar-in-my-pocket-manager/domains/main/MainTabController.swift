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
    
    private func setupTabBarController() {
        self.setViewControllers([
            HomeViewController.instance(),
            HomeViewController.instance(),
            HomeViewController.instance(),
            HomeViewController.instance()
        ], animated: true)
        self.tabBar.tintColor = .green
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = UIColor.gray5.cgColor
        self.tabBar.barTintColor = .white
    }
}
