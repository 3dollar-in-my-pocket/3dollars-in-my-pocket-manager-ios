import UIKit

import Base

final class SettingView: BaseView {
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .white
        $0.text = "setting_title".localized
    }
    
    let tableHeaderView = SettingTableHeaderView(frame: .init(
        x: 0,
        y: 0,
        width: UIScreen.main.bounds.width,
        height: SettingTableHeaderView.height
    ))
    
    let tableFooterView = SettingTableFooterView(frame: .init(
        x: 0,
        y: 0,
        width: UIScreen.main.bounds.width,
        height: SettingTableFooterView.height
    ))
    
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.rowHeight = SettingTableViewCell.height
        $0.register(
            SettingTableViewCell.self,
            forCellReuseIdentifier: SettingTableViewCell.registerId
        )
    }
    
    override func setup() {
        self.backgroundColor = .gray100
        self.tableView.tableHeaderView = self.tableHeaderView
        self.tableView.tableFooterView = self.tableFooterView
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
