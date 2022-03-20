import UIKit

extension UIViewController {
    static var topViewController: UIViewController? {
        var topViewController = UIApplication.shared.windows.first?.rootViewController
        
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController
    }
}
