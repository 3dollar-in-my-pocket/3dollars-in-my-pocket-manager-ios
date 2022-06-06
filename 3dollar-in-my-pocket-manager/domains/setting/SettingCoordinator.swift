import UIKit

import Base

protocol SettingCoordinator: BaseCoordinator, AnyObject {
    func showLogoutAlert()
    
    func showSignoutAlert()
    
    func goToSignin()
}

extension SettingCoordinator where Self: SettingViewController {
    func showLogoutAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: nil,
            message: "로그아웃하시겠습니까?",
            okButtonTitle: "로그아웃"
        ) {
            self.settingReactor.action.onNext(.tapLogout)
        }
    }
    
    func showSignoutAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: "회원탈퇴",
            message: "회원 탈퇴 시, 그동안의 데이터가 모두 삭제됩니다.\n회원탈퇴하시겠습니까?",
            okButtonTitle: "탈퇴"
        ) {
            self.settingReactor.action.onNext(.tapSignout)
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
}
