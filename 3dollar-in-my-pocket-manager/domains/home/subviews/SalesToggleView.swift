import UIKit

import RxSwift
import RxCocoa

final class SalesToggleView: BaseView {
    private let backgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.masksToBounds = true
    }
    
    private let offTitleLabel = UILabel().then {
        $0.font = .extraBold(size: 18)
        $0.textColor = .gray100
        $0.text = "home_off_title".localized
        $0.isHidden = true
    }
    
    private let offDescriptionLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .gray100
        $0.text = "home_off_description".localized
        $0.isHidden = true
    }
    
    private let onTitleLabel = UILabel().then {
        $0.font = .extraBold(size: 18)
        $0.textColor = .white
        $0.text = "home_on_title".localized
        $0.isHidden = true
    }
    
    private let onDescriptionLabel = UILabel().then {
        $0.font = .extraBold(size: 18)
        $0.textColor = .white
        $0.text = "home_on_description".localized
        $0.isHidden = true
    }
    
    private let badgeImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_badge")
    }
    
    fileprivate let toggleButton = UIButton().then {
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
    }
    
    override func setup() {
        self.addSubViews([
            self.backgroundView,
            self.offTitleLabel,
            self.offDescriptionLabel,
            self.onTitleLabel,
            self.onDescriptionLabel,
            self.badgeImageView,
            self.toggleButton
        ])
    }
    
    override func bindConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.offTitleLabel).offset(-24)
        }
        
        self.toggleButton.snp.makeConstraints { make in
            make.left.equalTo(self.backgroundView).offset(24)
            make.right.equalTo(self.backgroundView).offset(-24)
            make.bottom.equalTo(self.backgroundView).offset(-32)
            make.height.equalTo(48)
        }
        
        self.offDescriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.backgroundView).offset(26)
            make.bottom.equalTo(self.toggleButton.snp.top).offset(-28)
        }
        
        self.offTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.offDescriptionLabel)
            make.bottom.equalTo(self.offDescriptionLabel.snp.top).offset(-8)
        }
        
        self.onDescriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.backgroundView).offset(25)
            make.bottom.equalTo(self.toggleButton.snp.top).offset(-28)
        }
        
        self.onTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.onDescriptionLabel)
            make.bottom.equalTo(self.onDescriptionLabel.snp.top).offset(-2)
        }
        
        self.badgeImageView.snp.makeConstraints { make in
            make.top.equalTo(self.backgroundView).offset(24)
            make.right.equalTo(self.backgroundView).offset(-24)
            make.width.height.equalTo(40)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.backgroundView).priority(.high)
        }
    }
    
    fileprivate func setStatus(isOn: Bool) {
        self.offTitleLabel.isHidden = isOn
        self.offDescriptionLabel.isHidden = isOn
        self.onTitleLabel.isHidden = !isOn
        self.onDescriptionLabel.isHidden = !isOn
        self.toggleButton.setTitle(
            isOn ? "home_on_toggle".localized : "home_off_toggle".localized,
            for: .normal
        )
        self.toggleButton.setTitleColor(isOn ? .green : .white, for: .normal)
        
        UIView.transition(with: self, duration: 0.3) { [weak self] in
            self?.toggleButton.backgroundColor = isOn ? .white : .green
            self?.backgroundView.backgroundColor = isOn ? .green : .white
        }
    }
}

extension Reactive where Base: SalesToggleView {
    var isOn: Binder<Bool> {
        return Binder(self.base) { view, isOn in
            view.setStatus(isOn: isOn)
        }
    }
    
    var tapButton: ControlEvent<Void> {
        return self.base.toggleButton.rx.tap
    }
}
