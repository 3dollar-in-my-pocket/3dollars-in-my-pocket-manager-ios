import UIKit

final class DailyStatisticsView: BaseView {
    let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.register(
            DailyStatisticsTableViewCell.self,
            forCellReuseIdentifier: DailyStatisticsTableViewCell.registerId
        )
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
    }
    
    override func setup() {
        self.addSubViews([
            self.tableView
        ])
    }
    
    override func bindConstraints() {
        self.tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
//    func calculatorTableViewHeight(itemCount: Int) -> CGFloat {
//        let height = TotalStatisticsTableViewCell.height * CGFloat(itemCount) + 16
//
//        self.tableView.snp.updateConstraints { make in
//            make.height.equalTo(height)
//        }
//        return height
//    }
}
