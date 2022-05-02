import UIKit

final class EditScheduleView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
        $0.text = "edit_schedule_title".localized
    }
    
    private let mainDescriptionLabel = UILabel().then {
        $0.font = .regular(size: 24)
        $0.textColor = .black
        
        let string = "edit_schedule_main_description".localized
        let attributedString = NSMutableAttributedString(string: string)
        
        attributedString.addAttribute(
            .font,
            value: UIFont.bold(size: 24) as Any,
            range: (string as NSString).range(of: "영업 요일")
        )
        $0.attributedText = attributedString
    }
    
    private let subDescriptionLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .black
        $0.text = "edit_schedule_sub_description".localized
    }
    
    private let weekDayStackView = WeekDayStackView()
    
    let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.register(
            EditScheduleTableViewCell.self,
            forCellReuseIdentifier: EditScheduleTableViewCell.registerId
        )
        $0.rowHeight = EditScheduleTableViewCell.size.height
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("edit_schedule_save".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        $0.setBackgroundColor(color: .green, forState: .normal)
        $0.setBackgroundColor(color: .gray30, forState: .disabled)
    }
    
    override func setup() {
        self.backgroundColor = .gray0
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.mainDescriptionLabel,
            self.subDescriptionLabel,
            self.weekDayStackView,
            self.tableView,
            self.saveButton
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.mainDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.backButton.snp.bottom).offset(53)
        }
        
        self.subDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.mainDescriptionLabel.snp.bottom).offset(4)
        }
        
        self.weekDayStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.subDescriptionLabel.snp.bottom).offset(16)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.weekDayStackView.snp.bottom).offset(24)
            make.bottom.equalTo(self.saveButton.snp.top)
        }
        
        self.saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-64)
        }
    }
}
