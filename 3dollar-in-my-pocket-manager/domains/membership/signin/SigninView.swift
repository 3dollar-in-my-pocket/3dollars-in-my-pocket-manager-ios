import UIKit

final class SigninView: BaseView {
    let introImageButton = UIButton().then {
        $0.setImage(UIImage(named: "img_intro"), for: .normal)
        $0.contentMode = .scaleAspectFill
        $0.adjustsImageWhenHighlighted = false
    }
    
    let appleButton = SocialSigninButton(socialType: .apple)
    
    let kakaoButton = SocialSigninButton(socialType: .kakao)
    
    override func setup() {
        self.backgroundColor = .gray100
        self.addSubViews([
            self.introImageButton,
            self.appleButton,
            self.kakaoButton
        ])
    }
    
    override func bindConstraints() {
        self.introImageButton.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(106)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(self.introImageButton.snp.height)
        }
        
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
