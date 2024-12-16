import UIKit
import PermissionsKit

final class PermissionManager {
    static func requestPhotoLibrary(
        viewController: UIViewController,
        onSuccess: @escaping (() -> Void),
        onDenied: (() -> Void)? = nil
    ) {
        Permission.photoLibrary.request {
            if Permission.photoLibrary.authorized {
                onSuccess()
            } else {
                showDeniedAlert(viewController)
                onDenied?()
            }
        }
    }
    
    static func requestCamera(
        viewController: UIViewController,
        onSuccess: @escaping (() -> Void),
        onDenied: (() -> Void)? = nil
    ) {
        Permission.camera.request {
            if Permission.camera.authorized {
                onSuccess()
            } else {
                showDeniedAlert(viewController)
                onDenied?()
            }
        }
    }
    
    static func showDeniedAlert(_ viewController: UIViewController) {
        AlertUtils.showWithCancel(
            viewController: viewController,
            title: "authorization_denied_title".localized,
            message: "authorization_denied_description".localized,
            okButtonTitle: "authorization_setting".localized
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
