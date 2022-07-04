import UIKit

import Base

final class LoadingView: BaseView {
    let blurEffectView = UIVisualEffectView(
        effect: UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterialLight)
    ).then {
        $0.alpha = 0
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.blurEffectView,
            self.activityIndicator
        ])
    }
    
    override func bindConstraints() {
        self.blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
