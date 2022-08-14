import UIKit

import Base
import RxSwift
import RxCocoa

final class SalesToggleView: BaseView {
    private var timerDisposeBag = DisposeBag()
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 20
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
    
    private let timerView = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.backgroundColor = UIColor(r: 51, g: 209, b: 133)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.textColor = .white
        $0.font = .bold(size: 16)
    }
    
    private let onDescriptionLabel = UILabel().then {
        $0.font = .extraBold(size: 18)
        $0.textColor = .white
        $0.text = "home_on_description".localized
        $0.isHidden = true
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
            self.timerView,
            self.onDescriptionLabel,
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
        
        self.timerView.snp.makeConstraints { make in
            make.left.equalTo(self.onTitleLabel.snp.right).offset(4)
            make.centerY.equalTo(self.onTitleLabel)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.backgroundView).priority(.high)
        }
    }
    
    fileprivate func setStatus(isOn: Bool) {
        self.offTitleLabel.isHidden = isOn
        self.offDescriptionLabel.isHidden = isOn
        self.onTitleLabel.isHidden = !isOn
        self.timerView.isHidden = !isOn
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
    
    fileprivate func setTimer(startDate: Date) {
        self.resetTimer()
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .bind { [weak self] time in
                let dateFormatter = DateComponentsFormatter()
                var calendar = Calendar.current
                calendar.locale = Locale(identifier: "ko_KR")
                
                dateFormatter.unitsStyle = .full
                dateFormatter.calendar = calendar
                dateFormatter.allowedUnits = [.hour, .minute, .second]
                let timeDiff = Date().timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
                
                self?.timerView.text = dateFormatter.string(from: timeDiff)
            }
            .disposed(by: self.timerDisposeBag)
    }
    
    private func resetTimer() {
        self.timerDisposeBag = DisposeBag()
        self.timerView.text = nil
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
    
    var openTime: Binder<Date> {
        return Binder(self.base) { view, openTime in
            view.setTimer(startDate: openTime)
        }
    }
}
