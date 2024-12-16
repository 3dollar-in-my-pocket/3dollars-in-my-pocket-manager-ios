import UIKit

import Lottie

final class LoadingView: BaseView {
    let lottie = LottieAnimationView(name: "loading").then {
      $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
      $0.contentMode = .scaleAspectFit
      $0.loopMode = .loop
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.lottie
        ])
    }
    
    override func bindConstraints() {
        self.lottie.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
    }
    
    func startLoading() {
        self.lottie.play()
    }
    
    func stopLoading() {
        self.lottie.stop()
    }
}
