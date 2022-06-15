import UIKit

final class DailyStatisticsStackItemView: BaseView {
    static let height: CGFloat = 22
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = .gray95
    }
    
    private let countLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.font = .regular(size: 12)
        $0.textColor = .green
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 11
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.titleLabel,
            self.countLabel
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.countLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(Self.height)
        }
        
        self.snp.makeConstraints { make in
            make.top.equalTo(self.countLabel).priority(.high)
            make.bottom.equalTo(self.countLabel).priority(.high)
        }
    }
    
    func bind(statistic: Statistic) {
        self.titleLabel.text = "\(statistic.type.emoji) \(statistic.type.description)"
        self.countLabel.text = "\(statistic.count)개"
    }
}
