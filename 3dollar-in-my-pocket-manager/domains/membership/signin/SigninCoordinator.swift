import UIKit

protocol SigninCoordinator: AnyObject, BaseCoordinator {
    func pushSignup(socialType: SocialType, token: String, name: String?)
    
    func goToWaiting()
    
    func goToMain()
}

extension SigninCoordinator {
    func pushSignup(socialType: SocialType, token: String, name: String?) {
        let viewControler = SignupViewController.instance(socialType: socialType, token: token, name: name)
        
        self.presenter.navigationController?.pushViewController(viewControler, animated: true)
    }
    
    func goToWaiting() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
          }
        
        sceneDelegate.goToWaiting()
    }
    
    func goToMain() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToMain()
    }
}
