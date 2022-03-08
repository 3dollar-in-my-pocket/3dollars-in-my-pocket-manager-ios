import UIKit

protocol SigninCoordinator: AnyObject {
    func pushSignup(socialType: SocialType, token: String)
    
    func pushWaiting()
    
    func goToMain()
}

extension SigninCoordinator {
    func pushSignup(socialType: SocialType, token: String) {
        
    }
    
    func pushWaiting() {
        
    }
    
    func goToMain() {
        
    }
}
