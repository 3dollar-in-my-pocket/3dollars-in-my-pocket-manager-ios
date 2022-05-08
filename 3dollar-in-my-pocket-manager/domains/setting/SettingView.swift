import UIKit

final class SettingView: BaseView {
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .white
        $0.text = "setting_title".localized
    }
    
    let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
    }
    
    override func setup() {
        self.backgroundColor = .gray100
        self.addSubViews([
            self.titleLabel,
            self.tableView
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).offset(22)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(21)
        }
    }
}
