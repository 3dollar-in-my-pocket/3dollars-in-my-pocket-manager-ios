import UIKit

protocol SigninCoordinator: AnyObject, BaseCoordinator {
    func pushSignup(socialType: SocialType, token: String)
    
    func pushWaiting()
    
    func goToMain()
}

extension SigninCoordinator {
    func pushSignup(socialType: SocialType, token: String) {
        let viewControler = SignupViewController.instance()
        
        self.presenter.navigationController?.pushViewController(viewControler, animated: true)
    }
    
    func pushWaiting() {
        
    }
    
    func goToMain() {
        
    }
}
