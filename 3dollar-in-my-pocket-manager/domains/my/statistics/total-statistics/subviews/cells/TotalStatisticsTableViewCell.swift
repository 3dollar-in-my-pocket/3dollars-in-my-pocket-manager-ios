import UIKit

final class TotalStatisticsTableViewCell: BaseTableViewCell {
    static let registerId = "\(TotalStatisticsTableViewCell.self)"
    
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
    
    private let progressBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(r: 242, g: 251, b: 247)
        $0.layer.cornerRadius = 8
    }
    
    private let progressView = UIProgressView().then {
        $0.progressTintColor = .green
        $0.layer.cornerRadius = 4
        $0.trackTintColor = .clear
        $0.progress = 0.5
    }
    
    override func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.addSubViews([
            self.titleLabel,
            self.countLabel,
            self.progressBackgroundView,
            self.progressView
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.countLabel).offset(2)
        }
        
        self.countLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
        
        self.progressBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
        self.progressView.snp.makeConstraints { make in
            make.left.equalTo(self.progressBackgroundView).offset(4)
            make.top.equalTo(self.progressBackgroundView).offset(4)
            make.right.equalTo(self.progressBackgroundView).offset(-4)
            make.bottom.equalTo(self.progressBackgroundView).offset(-4)
        }
    }
    
    func bind(statistics: Statistic) {
        self.titleLabel.text = statistics.type.title
        self.countLabel.text = "\(statistics.count)개"
    }
}
