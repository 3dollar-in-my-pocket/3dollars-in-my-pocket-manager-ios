import UIKit

import Base

protocol SettingCoordinator: BaseCoordinator, AnyObject {
    func showLogoutAlert()
    
    func showSignoutAlert()
    
    func showCopyTokenSuccessAlert()
    
    func goToSignin()
    
    func goToKakaoTalkChannel()
    
    func pushFAQ()
    
    func goToPrivacy()
}

extension SettingCoordinator where Self: SettingViewController {
    func showLogoutAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: nil,
            message: "setting_logout_message".localized,
            okButtonTitle: "setting_logout".localized
        ) {
            self.settingReactor.action.onNext(.tapLogout)
        }
    }
    
    func showSignoutAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: "setting_signout".localized,
            message: "setting_signout_title".localized,
            okButtonTitle: "setting_signout_button".localized
        ) {
            self.settingReactor.action.onNext(.tapSignout)
        }
    }
    
    func showCopyTokenSuccessAlert() {
        AlertUtils.showWithAction(
            viewController: self,
            title: "setting_copy_token_title".localized,
            message: "setting_copy_token_description".localized,
            okbuttonTitle: "common_ok".localized) {
                
            }
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
    
    func goToKakaoTalkChannel() {
        guard let url = URL(string: Bundle.kakaoChannelUrl) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func pushFAQ() {
        let viewController = FAQViewController.instance()
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToPrivacy() {
        guard let url = URL(string: Bundle.privacyUrl) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
