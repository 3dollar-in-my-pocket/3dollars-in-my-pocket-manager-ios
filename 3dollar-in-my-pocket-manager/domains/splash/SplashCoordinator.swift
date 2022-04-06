import UIKit

protocol SplashCoordinator: AnyObject, BaseCoordinator {
    func goToSignin()
    
    func goToMain()
    
    func goToWaiting()
}

extension SplashCoordinator {
    func goToSignin() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToSignin()
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
    
    func goToWaiting() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToWaiting()
    }
}
