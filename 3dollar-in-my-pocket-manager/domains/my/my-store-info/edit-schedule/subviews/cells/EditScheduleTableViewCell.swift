import UIKit

import RxSwift
import Base

final class EditScheduleTableViewCell: UITableViewCell {
    static let registerId = "\(EditScheduleTableViewCell.self)"
    static let size = CGSize(
        width: UIScreen.main.bounds.width - 48,
        height: 224
    )
    var disposeBag = DisposeBag()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor(r: 0, g: 198, b: 103).cgColor
        $0.layer.shadowOpacity = 0.04
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 16)
        $0.textColor = .black
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private let workTimeLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.font = .regular(size: 12)
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.green.cgColor
        $0.textColor = .green
        $0.text = "edit_schedule_work_time".localized
    }
    
    let startTimeField = TextField().then {
        $0.setDatePicker()
    }
    
    private let dashLabel = UILabel().then {
        $0.text = "~"
        $0.font = .regular(size: 14)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    let endTimeField = TextField().then {
        $0.setDatePicker()
    }
    
    private let locationLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.font = .regular(size: 12)
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.green.cgColor
        $0.textColor = .green
        $0.text = "edit_schedule_location".localized
    }
    
    let locationField = TextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    private func setup() {
        self.contentView.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.addSubViews([
            self.containerView,
            self.titleLabel,
            self.workTimeLabel,
            self.startTimeField,
            self.dashLabel,
            self.endTimeField,
            self.locationLabel,
            self.locationField
        ])
    }
    
    private func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.locationField).offset(16)
            make.bottom.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
        }
        
        self.workTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.left.equalTo(self.titleLabel.snp.right).offset(18)
            make.height.equalTo(22)
        }
        
        self.startTimeField.snp.makeConstraints { make in
            make.left.equalTo(self.workTimeLabel)
            make.width.equalTo(100)
            make.top.equalTo(self.workTimeLabel.snp.bottom).offset(8)
            make.height.equalTo(48)
        }
        
        self.endTimeField.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-16)
            make.centerY.equalTo(self.startTimeField)
            make.top.equalTo(self.startTimeField)
            make.bottom.equalTo(self.startTimeField)
            make.width.equalTo(100)
        }
        
        self.dashLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.startTimeField)
            make.left.equalTo(self.startTimeField.snp.right)
            make.right.equalTo(self.endTimeField.snp.left)
        }
        
        self.locationLabel.snp.makeConstraints { make in
            make.left.equalTo(self.workTimeLabel)
            make.height.equalTo(22)
            make.top.equalTo(self.startTimeField.snp.bottom).offset(20)
        }
        
        self.locationField.snp.makeConstraints { make in
            make.left.equalTo(self.startTimeField)
            make.right.equalTo(self.endTimeField)
            make.height.equalTo(48)
        }
    }
    
    func bind(appearanceDay: AppearanceDay) {
        if !appearanceDay.openingHours.startTime.isEmpty {
            let startTime = DateUtils.toDate(
                dateString: appearanceDay.openingHours.startTime,
                format: "HH:mm"
            )
            
            self.startTimeField.setDate(date: startTime)
        }
        
        if !appearanceDay.openingHours.endTime.isEmpty {
            let endTime = DateUtils.toDate(
                dateString: appearanceDay.openingHours.endTime,
                format: "HH:mm"
            )
            
            self.endTimeField.setDate(date: endTime)
        }
        self.titleLabel.text =  appearanceDay.dayOfTheWeek.fullText
        self.locationField.setText(text: appearanceDay.locationDescription)
    }
}
