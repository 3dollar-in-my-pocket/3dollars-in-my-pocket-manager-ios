import UIKit

import Base

final class SigninView: BaseView {
    let appleButton = SocialSigninButton(socialType: .apple)
    
    let kakaoButton = SocialSigninButton(socialType: .kakao)
    
    let naverButton = SocialSigninButton(socialType: .naver)
    
    override func setup() {
        self.backgroundColor = .gray0
        self.addSubViews([
            self.appleButton,
            self.kakaoButton,
            self.naverButton
        ])
    }
    
    override func bindConstraints() {
        self.naverButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-66)
        }
        
        self.kakaoButton.snp.makeConstraints { make in
            make.left.equalTo(self.naverButton)
            make.right.equalTo(self.naverButton)
            make.bottom.equalTo(self.naverButton.snp.top).offset(-16)
        }
        
        self.appleButton.snp.makeConstraints { make in
            make.left.equalTo(self.naverButton)
            make.right.equalTo(self.naverButton)
            make.bottom.equalTo(self.kakaoButton.snp.top).offset(-16)
        }
    }
}
