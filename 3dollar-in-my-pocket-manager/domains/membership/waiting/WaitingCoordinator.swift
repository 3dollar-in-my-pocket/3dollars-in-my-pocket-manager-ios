import Foundation
import MessageUI

protocol WaitingCoordinator: AnyObject, BaseCoordinator {
    func showMailComposer(message: String)
    
    func goToSignin()
}

extension WaitingCoordinator where Self: WaitingViewController {
    func showMailComposer(message: String) {
        guard MFMailComposeViewController.canSendMail() else { return}
        let composer = MFMailComposeViewController().then {
            $0.mailComposeDelegate = self
            $0.setToRecipients(["3dollarinmypocket@gmail.com"])
            $0.setSubject("가슴속 3천원 사장님 문의")
            $0.setMessageBody(message, isHTML: false)
        }

        self.present(composer, animated: true, completion: nil)
    }
    
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
