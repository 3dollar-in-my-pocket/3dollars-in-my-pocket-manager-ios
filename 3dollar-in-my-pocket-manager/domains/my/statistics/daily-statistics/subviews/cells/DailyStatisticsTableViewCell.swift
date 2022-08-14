import UIKit

import Base

final class DailyStatisticsTableViewCell: BaseTableViewCell {
    static let registerId = "\(DailyStatisticsTableViewCell.self)"
    
    private let dayView = DailyStatisticsDayView()
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.layoutMargins = .init(top: 21, left: 16, bottom: 21, right: 16)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.addSubViews([
            self.dayView,
            self.stackView
        ])
    }
    
    override func bindConstraints() {
        self.dayView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(64)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.left.equalTo(self.dayView.snp.right).offset(11)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.right.equalToSuperview().offset(-24)
        }
    }
    
    func bind(statisticGroup: StatisticGroup) {
        self.dayView.bind(dateString: statisticGroup.date)
        for statistics in statisticGroup.feedbacks {
            let stackItemView = DailyStatisticsStackItemView()
            
            stackItemView.bind(statistic: statistics)
            self.stackView.addArrangedSubview(stackItemView)
        }
    }
}
