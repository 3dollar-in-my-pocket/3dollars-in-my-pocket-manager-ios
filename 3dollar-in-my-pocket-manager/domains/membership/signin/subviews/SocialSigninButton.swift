import UIKit

import Base
import RxSwift
import RxCocoa

final class SocialSigninButton: BaseView {
    fileprivate let tapGesture = UITapGestureRecognizer()
    
    private let iconImage = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textAlignment = .center
    }
    
    init(socialType: SocialType) {
        super.init(frame: .zero)
        
        self.bind(socialType: socialType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.layer.cornerRadius = 20
        self.addGestureRecognizer(self.tapGesture)
        self.addSubViews([
            self.iconImage,
            self.titleLabel
        ])
    }
    
    override func bindConstraints() {
        self.iconImage.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.right.equalTo(self.titleLabel.snp.left).offset(-8)
            make.centerY.equalTo(self.titleLabel)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    private func bind(socialType: SocialType) {
        switch socialType {
        case .apple:
            self.iconImage.image = UIImage(named: "ic_apple")
            self.titleLabel.text = "Sign in with Apple"
            self.titleLabel.textColor = UIColor(r: 0, g: 0, b: 0)
            self.backgroundColor = UIColor(r: 255, g: 255, b: 255)
            
        case .kakao:
            self.iconImage.image = UIImage(named: "ic_kakao")
            self.titleLabel.text = "카카오 계정으로 로그인"
            self.titleLabel.textColor = UIColor(r: 56, g: 30, b: 31)
            self.backgroundColor = UIColor(r: 247, g: 227, b: 23)
            
        case .google:
            break
        }
    }
}

extension Reactive where Base: SocialSigninButton {
    var tap: ControlEvent<Void> {
        return ControlEvent(events: base.tapGesture.rx.event.map { _ in })
    }
}
