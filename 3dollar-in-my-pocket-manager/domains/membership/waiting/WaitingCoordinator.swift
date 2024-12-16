import Foundation
import MessageUI

protocol WaitingCoordinator: AnyObject, BaseCoordinator {
    func goToSignin()
}

extension WaitingCoordinator where Self: WaitingViewController {
    func goToSignin() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToSignin()
    }
}
