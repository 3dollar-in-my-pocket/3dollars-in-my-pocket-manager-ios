import UIKit

final class DailyStatisticsDayView: BaseView {
    enum Layout {
        static let size = CGSize(width: 64, height: 64)
    }
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 12)
        label.textColor = .white
        return label
    }()
    
    override func setup() {
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowOpacity = 0.04
        
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([
            dayLabel,
            dateLabel
        ])
        
        dayLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(14)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(dayLabel.snp.bottom).offset(2)
        }
    }
    
    func bind(dateString: String) {
        let date = DateUtils.toDate(dateString: dateString, format: "yyyy-MM-dd")
        let isToday = dateString == DateUtils.todayString(format: "yyyy-MM-dd")
        
        dayLabel.text = "\(date.get(.day))일"
        dateLabel.text = "\(date.get(.year)).\(date.get(.month))"
        backgroundColor = isToday ? .green : .white
        dayLabel.textColor = isToday ? .white : .green
        dateLabel.textColor = isToday ? .white : .gray30
        layer.shadowColor = isToday ? UIColor(r: 0, g: 198, b: 103).cgColor : UIColor.black.cgColor
    }
}
