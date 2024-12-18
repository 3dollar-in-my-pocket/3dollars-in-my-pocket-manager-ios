import UIKit

protocol BaseCoordinator {
    var presenter: BaseViewController { get }
    
    func popViewController(animated: Bool)
    
    func showErrorAlert(error: Error)
    
    func openURL(url: String)
    
    func showLoading(isShow: Bool)
}

extension BaseCoordinator where Self: BaseViewController {
    var presenter: BaseViewController {
        return self
    }
    
    func popViewController(animated: Bool) {
        self.presenter.navigationController?.popViewController(animated: true)
    }
    
    
    func showErrorAlert(error: Error) {
        if let httpError = error as? HTTPError,
           httpError == .unauthorized {
            AlertUtils.showWithAction(
                viewController: self,
                title: nil,
                message: httpError.description,
                okbuttonTitle: "common_ok".localized
            ) {
                Preference.shared.clear()
                self.goToSignin()
            }
        } else if let localizedError = error as? LocalizedError {
            AlertUtils.showWithAction(
                viewController: self,
                message: localizedError.errorDescription,
                onTapOk: nil
            )
        } else {
            AlertUtils.showWithAction(
                viewController: self,
                message: error.localizedDescription,
                onTapOk: nil
            )
        }
    }
    
    func openURL(url: String) {
        guard let url = URL(string: url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showLoading(isShow: Bool) {
        LoadingManager.shared.showLoading(isShow: isShow)
    }
    
    private func goToSignin() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToSignin()
    }
}
