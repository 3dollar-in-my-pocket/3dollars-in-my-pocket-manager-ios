import UIKit

struct UIUtils {
    static var windowBounds: CGRect {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .zero }
        
        return window.screen.bounds
    }
    
    static var bottomSafeAreaInset: CGFloat {
        if #available(iOS 15.0, *) {
            let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return window?.keyWindow?.safeAreaInsets.bottom ?? .zero
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? .zero
        }
    }
    
    static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .filter({ $0.activationState == .foregroundActive })
        .compactMap({ $0 as? UIWindowScene })
        .first?.windows
        .filter({ $0.isKeyWindow }).first?.rootViewController) -> UIViewController? {
            
            if let nav = base as? UINavigationController {
                return topViewController(base: nav.visibleViewController)
            }
            
            if let tab = base as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return topViewController(base: selected)
                }
            }
            
            if let presented = base?.presentedViewController {
                return topViewController(base: presented)
            }
            
            return base
        }
}
