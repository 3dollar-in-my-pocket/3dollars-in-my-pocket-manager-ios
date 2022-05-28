import UIKit

final class DailyStatisticsTableViewCell: BaseTableViewCell {
    static let registerId = "\(DailyStatisticsTableViewCell.self)"
    
    private let dayView = DailyStatisticsDayView()
    
    private let staciView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.layoutMargins = .init(top: 21, left: 0, bottom: 21, right: 0)
        $0.backgroundColor = .white
    }
    
    override func setup() {
        self.addSubViews([
            self.dayView,
            self.staciView
        ])
    }
    
    override func bindConstraints() {
        self.dayView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(64)
        }
        
        self.staciView.snp.makeConstraints { make in
            make.left.equalTo(self.dayView.snp.right).offset(11)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-24)
        }
    }
}
