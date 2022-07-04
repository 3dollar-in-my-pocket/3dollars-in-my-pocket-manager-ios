import UIKit

import Base

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
            make.height.equalTo(1000)
        }
    }
    
    func calculatorTableViewHeight(statisticGroups: [StatisticGroup]) -> CGFloat {
        var height: CGFloat = 0
        
        for statistic in statisticGroups {
            var stackViewHeight
            = CGFloat(statistic.feedbacks.count) * DailyStatisticsStackItemView.height
            stackViewHeight += CGFloat(statistic.feedbacks.count - 1) * 16 // space
            stackViewHeight += 42 // contentInset
            let dayViewHeight: CGFloat = 64
            
            if dayViewHeight >= stackViewHeight {
                height += dayViewHeight
            } else {
                height += stackViewHeight
            }
            height += 20
        }
        self.tableView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        
        return height
    }
}
