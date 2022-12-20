import UIKit

struct AlertUtils {
    static func showWithAction(
        viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        okbuttonTitle: String = "확인",
        onTapOk: (() -> Void)?
    ) {
        let okAction = UIAlertAction(title: okbuttonTitle, style: .default) { action in
            onTapOk?()
        }
        
        Self.show(viewController: viewController, title: title, message: message, [okAction])
    }
    
    static func showWithCancel(
        viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        okButtonTitle: String = "확인",
        onTapOk: @escaping () -> Void
    ) {
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { (action) in
            onTapOk()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        show(viewController: viewController, title: title, message: message, [okAction, cancelAction])
    }
    
    static private func show(
        viewController: UIViewController,
        title: String?,
        message: String?,
        _ actions: [UIAlertAction]
    ) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            controller.addAction(action)
        }
        
        viewController.present(controller, animated: true)
    }
}


