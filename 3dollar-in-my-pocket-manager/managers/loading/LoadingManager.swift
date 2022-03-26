import UIKit

protocol LoadingManagerProtocol: AnyObject {
    func showLoading(isShow: Bool)
}

final class LoadingManager: LoadingManagerProtocol {
    static let shared = LoadingManager()
    
    private let loadingView = LoadingView(frame: UIScreen.main.bounds)
    
    func showLoading(isShow: Bool) {
        if isShow {
            self.showLoading()
        } else {
            self.hideLoading()
        }
    }
    
    private func showLoading() {
        guard let rootView = UIViewController.topViewController?.view else {
            return
        }
        
        rootView.addSubview(self.loadingView)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.loadingView.blurEffectView.alpha = 1.0
        } completion: { [weak self] _ in
            self?.loadingView.activityIndicator.startAnimating()
        }
    }
    
    private func hideLoading() {
        self.loadingView.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.loadingView.blurEffectView.alpha = 0.0
        } completion: { [weak self] _ in
            self?.loadingView.removeFromSuperview()
        }
    }
}
