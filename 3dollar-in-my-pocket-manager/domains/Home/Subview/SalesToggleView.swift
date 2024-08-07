import UIKit
import Combine

final class SalesToggleView: BaseView {
    private var cancellable: AnyCancellable?
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let offTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .extraBold(size: 18)
        label.textColor = .gray100
        label.text = "home_off_title".localized
        label.isHidden = true
        return label
    }()
    
    private let offDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray100
        label.text = "home_off_description".localized
        label.isHidden = true
        return label
    }()
    
    private let onTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .extraBold(size: 18)
        label.textColor = .white
        label.text = "home_on_title".localized
        label.isHidden = true
        return label
    }()
    
    private let timerView: PaddingLabel = {
        let label = PaddingLabel(topInset: 4, bottomInset: 4, leftInset: 8, rightInset: 8)
        label.backgroundColor = UIColor(r: 51, g: 209, b: 133)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.textColor = .white
        label.font = .bold(size: 16)
        return label
    }()
    
    private let onDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .extraBold(size: 18)
        label.textColor = .white
        label.text = "home_on_description".localized
        label.isHidden = true
        return label
    }()
    
    
    let toggleButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .bold(size: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func setup() {
        super.setup()
        
        addSubViews([
            backgroundView,
            offTitleLabel,
            offDescriptionLabel,
            onTitleLabel,
            timerView,
            onDescriptionLabel,
            toggleButton
        ])
        
        backgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(offTitleLabel).offset(-24)
        }
        
        toggleButton.snp.makeConstraints { make in
            make.left.equalTo(backgroundView).offset(24)
            make.right.equalTo(backgroundView).offset(-24)
            make.bottom.equalTo(backgroundView).offset(-32)
            make.height.equalTo(48)
        }
        
        offDescriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(backgroundView).offset(26)
            make.bottom.equalTo(toggleButton.snp.top).offset(-28)
        }
        
        offTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(offDescriptionLabel)
            make.bottom.equalTo(offDescriptionLabel.snp.top).offset(-8)
        }
        
        onDescriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(backgroundView).offset(25)
            make.bottom.equalTo(toggleButton.snp.top).offset(-28)
        }
        
        onTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(onDescriptionLabel)
            make.bottom.equalTo(onDescriptionLabel.snp.top).offset(-2)
        }
        
        timerView.snp.makeConstraints { make in
            make.left.equalTo(onTitleLabel.snp.right).offset(4)
            make.centerY.equalTo(onTitleLabel)
        }
        
        snp.makeConstraints { make in
            make.edges.equalTo(backgroundView).priority(.high)
        }
    }
    
    func bindStatus(isOn: Bool) {
        offTitleLabel.isHidden = isOn
        offDescriptionLabel.isHidden = isOn
        onTitleLabel.isHidden = !isOn
        timerView.isHidden = !isOn
        onDescriptionLabel.isHidden = !isOn
        toggleButton.setTitle(
            isOn ? "home_on_toggle".localized : "home_off_toggle".localized,
            for: .normal
        )
        toggleButton.setTitleColor(isOn ? .green : .white, for: .normal)
        
        UIView.transition(with: self, duration: 0.3) { [weak self] in
            self?.toggleButton.backgroundColor = isOn ? .white : .green
            self?.backgroundView.backgroundColor = isOn ? .green : .white
        }
    }
    
    func bindTimer(startDate: Date) {
        resetTimer()
        
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                let dateFormatter = DateComponentsFormatter()
                var calendar = Calendar.current
                calendar.locale = Locale(identifier: "ko_KR")
                
                dateFormatter.unitsStyle = .full
                dateFormatter.calendar = calendar
                dateFormatter.allowedUnits = [.hour, .minute, .second]
                let timeDiff = Date().timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
                
                self?.timerView.text = dateFormatter.string(from: timeDiff)
            }
    }
    
    private func resetTimer() {
        cancellable?.cancel()
        cancellable = nil
        timerView.text = nil
    }
}
