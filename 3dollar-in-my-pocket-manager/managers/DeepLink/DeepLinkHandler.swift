import UIKit
import OSLog

protocol DeepLinkHandlerProtocol: AnyObject {
    func handle(_ urlString: String)
    
    func handleReservedDeepLink()
}


final class DeepLinkHandler: DeepLinkHandlerProtocol {
    static let shared = DeepLinkHandler()
    
    private var canHandleDeepLink: Bool {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController
        
        if let navigationViewController = rootViewController as? UINavigationController {
            return navigationViewController.topViewController is MainTabController
        } else {
            return false
        }
    }
    
    private var reservedDeepLink: String?
    
    func handle(_ urlString: String) {
        guard canHandleDeepLink else {
            reservedDeepLink = urlString
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        var path: String? = nil
        
        if isAppScheme(url: url) {
            path = (url.host ?? "") + url.path
        }
        
        guard let path else { return }
        let deepLinkPath = DeeplinkPath(value: path)
        
        switch deepLinkPath {
        case .reviewList:
            let viewModel = ReviewListViewModel()
            let viewController = ReviewListViewController(viewModel: viewModel)
            
            route(viewController)
        case .unknown:
            os_log(.debug, "🔴알 수 없는 형태의 딥링크입니다. %{PUBLIC}@", urlString)
            break
        }
    }
    
    func handleReservedDeepLink() {
        guard let reservedDeepLink, canHandleDeepLink else { return }
        
        handle(reservedDeepLink)
        self.reservedDeepLink = nil
    }
    
    private func isAppScheme(url: URL) -> Bool {
        return url.scheme == Bundle.deeplinkScheme && url.host.isNotNil
    }
    
    private func route(_ viewController: UIViewController) {
        guard let rootViewController = SceneDelegate.shared?.window?.rootViewController else { return }
        let topViewController = UIUtils.topViewController(base: rootViewController)
        
        if viewController is UINavigationController {
            topViewController?.present(viewController, animated: true)
        } else if let navigationController = topViewController?.navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if let navigationController = topViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if let tabBarController = topViewController as? UITabBarController,
                  let navigationController = tabBarController.selectedViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            navigationController.modalPresentationStyle = .overCurrentContext
            topViewController?.present(navigationController, animated: true)
        }
    }
}
