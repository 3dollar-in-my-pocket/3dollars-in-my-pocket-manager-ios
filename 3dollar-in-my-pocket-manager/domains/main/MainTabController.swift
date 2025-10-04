import UIKit
import Combine

import RxSwift

final class MainTabController: UITabBarController {
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let disposeBag = DisposeBag()
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
        
        setupTabBarController()
        feedbackGenerator.prepare()
        
        bind()
        viewModel.input.firstLoad.send(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DeepLinkHandler.shared.handleReservedDeepLink()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        feedbackGenerator.selectionChanged()
        
        guard let tabBarTag = TabBarTag(rawValue: item.tag) else { return }
        
        switch tabBarTag {
        case .home:
            LogManager.shared.sendEvent(.init(
                screen: .mainTab,
                eventName: .tapBottomTab,
                extraParameters: [.tab: "home"]
            ))
            
            self.tabBar.overrideUserInterfaceStyle = .light
            
        case .myPage:
            LogManager.shared.sendEvent(.init(
                screen: .mainTab,
                eventName: .tapBottomTab,
                extraParameters: [.tab: "my"]
            ))
            
            self.tabBar.overrideUserInterfaceStyle = .light
            
        case .ai:
            self.tabBar.overrideUserInterfaceStyle = .light
            LogManager.shared.sendEvent(.init(
                screen: .mainTab,
                eventName: .tapBottomTab,
                extraParameters: [.tab: "ai"]
            ))
            
        case .setting:
            LogManager.shared.sendEvent(.init(
                screen: .mainTab,
                eventName: .tapBottomTab,
                extraParameters: [.tab: "setting"]
            ))
            
            self.tabBar.overrideUserInterfaceStyle = .dark
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
        let homeViewController = createHomeViewController()
        let settingViewController = SettingViewController.instance()
        
        if Preference.shared.enableAIRecommendation {
            setViewControllers([
                homeViewController,
                myPageViewController,
                AIViewController(viewModel: AIViewModel()),
                settingViewController
            ], animated: true)
        } else {
            setViewControllers([
                homeViewController,
                myPageViewController,
                settingViewController
            ], animated: true)
        }
        
        self.tabBar.tintColor = .green
        self.tabBar.barTintColor = .white
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
