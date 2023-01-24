import UIKit

import Lottie

final class SplashView: BaseView {
    let lottieView = AnimationView(name: "splash").then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .playOnce
    }
    
    override func setup() {
        self.backgroundColor = .gray100
        self.addSubViews([
            self.lottieView
        ])
    }
    
    override func bindConstraints() {
        self.lottieView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(UIScreen.main.bounds.width)
        }
    }
    
    func startLottie(completion: @escaping () -> Void) {
        self.lottieView.play { _ in
            completion()
        }
    }
}
