import UIKit

final class SettingViewController: BaseViewController {
    private let settingView = SettingView()
    
    static func instance() -> UINavigationController {
        let viewController = SettingViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_home"),
                tag: TabBarTag.setting.rawValue
            )
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
        }
    }
    
    override func loadView() {
        self.view = self.settingView
    }
}
