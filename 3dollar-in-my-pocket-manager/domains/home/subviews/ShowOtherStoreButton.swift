import UIKit

import RxSwift
import RxCocoa

final class ShowOtherButton: BaseView {
    fileprivate let tapGesture = UITapGestureRecognizer()
    
    private let backgroundView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .white
    }
    
    private let checkImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_check")
        $0.isHidden = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = .gray100
        $0.text = "다른 푸드트럭 보기"
        $0.setKern(kern: -0.4)
    }
    
    override func setup() {
        self.addGestureRecognizer(self.tapGesture)
        self.addSubViews([
            self.backgroundView,
            self.checkImageView,
            self.titleLabel
        ])
    }
    
    override func bindConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalTo(self.titleLabel).offset(11)
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        self.checkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.left.equalTo(self.backgroundView).offset(12)
            make.centerY.equalTo(self.backgroundView)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.checkImageView.snp.right).offset(8)
            make.centerY.equalTo(self.backgroundView)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.backgroundView).priority(.high)
        }
    }
    
    fileprivate func setShowOtherStores(isShow: Bool) {
        self.checkImageView.isHidden = !isShow
    }
}

extension Reactive where Base: ShowOtherButton {
    var tap: ControlEvent<Void> {
        return ControlEvent(events: base.tapGesture.rx.event.map { _ in Void() })
    }
    
    var isShowOtherStore: Binder<Bool> {
        return Binder(self.base) { view, isShowOtherStore in
            view.setShowOtherStores(isShow: isShowOtherStore)
        }
    }
}
