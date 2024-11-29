import UIKit
import Combine

import RxSwift

final class MainTabController: UITabBarController {
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let disposeBag = DisposeBag()
    private let borderLayer = CALayer()
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let myPageViewController: UINavigationController = {
        let viewController = MyPageViewController(viewModel: MyPageViewModel())
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        return navigationController
    }()
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        bind()
        viewModel.input.firstLoad.send(())
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
    
    private func bind() {
        viewModel.output.showMessageTooltip
            .main
            .withUnretained(self)
            .sink { (owner: MainTabController, _) in
                owner.showMessageTooltip()
            }
            .store(in: &cancellables)
    }
    
    private func setupTabBarController() {
        self.setViewControllers([
            createHomeViewController(),
            myPageViewController,
            SettingViewController.instance()
        ], animated: true)
        
        self.borderLayer.backgroundColor = UIColor.gray5.cgColor
        self.borderLayer.frame = .init(x: 0, y: 0, width: self.tabBar.frame.size.width, height: 1)
        
        self.tabBar.tintColor = .green
        self.tabBar.barTintColor = .white
        self.tabBar.backgroundColor = .white
        self.tabBar.layer.addSublayer(self.borderLayer)
    }
    
    private func createHomeViewController() -> UINavigationController {
        let viewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        return navigationController
    }
    
    private func showMessageTooltip() {
        guard let myPageIndex = tabBar.items?.firstIndex(where: { $0.tag ==  TabBarTag.myPage.rawValue }),
              let tabBarButtons = tabBar.subviews.filter({ $0 is UIControl }) as? [UIControl],
              myPageIndex < tabBarButtons.count,
              let myPageTabView = tabBarButtons[safe: myPageIndex] else { return }
        
        let tooltipView = TooltipView(emoji: "📢", message: Strings.Main.messageTooltip, tailDirection: .bottomCenter)
        view.addSubview(tooltipView)
        tooltipView.snp.makeConstraints {
            $0.centerX.equalTo(myPageTabView)
            $0.bottom.equalTo(myPageTabView.snp.top).offset(4)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.3, animations: {
                tooltipView.alpha = 0
            }) { _ in
                tooltipView.removeFromSuperview()
            }
        }
    }
}
