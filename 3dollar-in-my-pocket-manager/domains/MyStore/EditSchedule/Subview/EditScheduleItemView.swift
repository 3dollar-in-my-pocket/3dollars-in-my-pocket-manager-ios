import UIKit

final class EditScheduleItemView: BaseView {
    static let size = CGSize(
        width: UIScreen.main.bounds.width - 48,
        height: 208
    )
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor(r: 0, g: 198, b: 103).cgColor
        view.layer.shadowOpacity = 0.04
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 16)
        label.textColor = .black
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let workTimeLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 4, bottomInset: 4, leftInset: 8, rightInset: 8)
        label.font = .regular(size: 12)
        label.layer.cornerRadius = 11
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.green.cgColor
        label.textColor = .green
        label.text = "edit_schedule_work_time".localized
        return label
    }()
    
    let startTimeField: TextField = {
        let field = TextField()
        field.setDatePicker()
        return field
    }()
    
    private let dashLabel: UILabel = {
        let label = UILabel()
        label.text = "~"
        label.font = .regular(size: 14)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    let endTimeField: TextField = {
        let field = TextField()
        field.setDatePicker()
        return field
    }()
    
    private let locationLabel: PaddingLabel = {
       let label = PaddingLabel(topInset: 4, bottomInset: 4, leftInset: 8, rightInset: 8)
        label.font = .regular(size: 12)
        label.layer.cornerRadius = 11
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.green.cgColor
        label.textColor = .green
        label.text = "edit_schedule_location".localized
        return label
    }()
    
    let locationField = TextField()
    
    override func setup() {
        backgroundColor = .clear
        setupLayout()
    }
    
    func bind(appearanceDay: BossStoreAppearanceDayResponse) {
        if !appearanceDay.openingHours.startTime.isEmpty {
            let startTime = DateUtils.toDate(
                dateString: appearanceDay.openingHours.startTime,
                format: "HH:mm"
            )
            
            startTimeField.setDate(date: startTime)
        }
        
        if !appearanceDay.openingHours.endTime.isEmpty {
            let endTime = DateUtils.toDate(
                dateString: appearanceDay.openingHours.endTime,
                format: "HH:mm"
            )
            
            endTimeField.setDate(date: endTime)
        }
        titleLabel.text =  appearanceDay.dayOfTheWeek.fullText
        locationField.setText(text: appearanceDay.locationDescription)
    }
    
    private func setupLayout() {
        addSubViews([
            containerView,
            titleLabel,
            workTimeLabel,
            startTimeField,
            dashLabel,
            endTimeField,
            locationLabel,
            locationField
        ])
        
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(locationField).offset(16)
            make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(16)
            make.top.equalTo(containerView).offset(16)
        }
        
        workTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(18)
            make.height.equalTo(22)
        }
        
        startTimeField.snp.makeConstraints { make in
            make.leading.equalTo(workTimeLabel)
            make.width.equalTo(100)
            make.top.equalTo(workTimeLabel.snp.bottom).offset(8)
            make.height.equalTo(48)
        }
        
        endTimeField.snp.makeConstraints { make in
            make.trailing.equalTo(containerView).offset(-16)
            make.centerY.equalTo(startTimeField)
            make.top.equalTo(startTimeField)
            make.bottom.equalTo(startTimeField)
            make.width.equalTo(100)
        }
        
        dashLabel.snp.makeConstraints { make in
            make.centerY.equalTo(startTimeField)
            make.leading.equalTo(startTimeField.snp.trailing)
            make.trailing.equalTo(endTimeField.snp.leading)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(workTimeLabel)
            make.height.equalTo(22)
            make.top.equalTo(startTimeField.snp.bottom).offset(20)
        }
        
        locationField.snp.makeConstraints {
            $0.leading.equalTo(startTimeField)
            $0.trailing.equalTo(endTimeField)
            $0.height.equalTo(48)
            $0.top.equalTo(locationLabel.snp.bottom).offset(4)
        }
    }
}
