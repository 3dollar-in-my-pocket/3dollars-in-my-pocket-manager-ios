import UIKit

final class DailyStatisticsDayView: BaseView {
    private let dayLabel = UILabel().then {
        $0.font = .bold(size: 16)
        $0.textColor = .white
        $0.text = "10일"
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = .white
        $0.text = "2022.01"
    }
    
    override func setup() {
        self.layer.cornerRadius = 16
        self.layer.shadowColor = UIColor(r: 0, g: 198, b: 103).cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowOpacity = 0.14
        self.addSubViews([
            self.dayLabel,
            self.dateLabel
        ])
    }
    
    override func bindConstraints() {
        self.dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(14)
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.dayLabel.snp.bottom).offset(2)
        }
    }
}
