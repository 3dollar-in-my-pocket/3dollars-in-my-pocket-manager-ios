import UIKit

import Base

final class SigninView: BaseView {
    let appleButton = SocialSigninButton(socialType: .apple)
    
    let kakaoButton = SocialSigninButton(socialType: .kakao)
    
    override func setup() {
        self.backgroundColor = .gray0
        self.addSubViews([
            self.appleButton,
            self.kakaoButton
        ])
    }
    
    override func bindConstraints() {
        self.kakaoButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-122)
        }
        
        self.appleButton.snp.makeConstraints { make in
            make.left.equalTo(self.kakaoButton)
            make.right.equalTo(self.kakaoButton)
            make.bottom.equalTo(self.kakaoButton.snp.top).offset(-16)
        }
    }
}
