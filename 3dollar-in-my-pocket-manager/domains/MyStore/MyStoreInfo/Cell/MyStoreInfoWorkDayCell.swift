import UIKit

final class MyStoreInfoWorkDayCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 86
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let weekDayLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 14)
        label.textColor = .gray95
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray70
        label.textAlignment = .right
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray70
        label.textAlignment = .right
        return label
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            weekDayLabel,
            timeLabel,
            locationLabel
        ])
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        weekDayLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.top.equalTo(containerView).offset(16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(containerView).offset(-16)
            make.top.equalTo(weekDayLabel)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.right.equalTo(containerView).offset(-16)
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
        }
    }
    
    func bind(appearanceDay: BossStoreAppearanceDayResponse) {
        weekDayLabel.text = appearanceDay.dayOfTheWeek.fullText
        if appearanceDay.dayOfTheWeek == .saturday || appearanceDay.dayOfTheWeek == .sunday {
            weekDayLabel.textColor = .red
        } else {
            weekDayLabel.textColor = .gray95
        }
        if appearanceDay.isClosedDay {
            timeLabel.text = "my_store_info_appearance_closed_day".localized
            timeLabel.textColor = .red
            locationLabel.text = "-"
        } else {
            timeLabel.text
            = "\(appearanceDay.openingHours.startTime) - \(appearanceDay.openingHours.endTime)"
            timeLabel.textColor = .gray70
            locationLabel.text = appearanceDay.locationDescription
        }
    }
}
