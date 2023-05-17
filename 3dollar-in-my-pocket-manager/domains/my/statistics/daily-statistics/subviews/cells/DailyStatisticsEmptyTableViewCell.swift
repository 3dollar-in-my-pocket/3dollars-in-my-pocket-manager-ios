import UIKit

final class DailyStatisticsEmptyTableViewCell: BaseTableViewCell {
    static let registerId = "\(DailyStatisticsEmptyTableViewCell.self)"
    static let height: CGFloat = 68
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    private let emojiLabel = UILabel().then {
        $0.text = "🥲"
        $0.font = .systemFont(ofSize: 14)
    }
    
    private let messageLabel = UILabel().then {
        $0.text = "아직 정보가 없어요"
        $0.textColor = .gray95
        $0.font = .bold(size: 14)
    }
    
    private let countLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.layer.cornerRadius = 13
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray30.cgColor
        $0.text = "0개"
        $0.textColor = .gray30
        $0.font = .regular(size: 12)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.addSubViews([
            self.containerView,
            self.emojiLabel,
            self.messageLabel,
            self.countLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
        }
        
        self.emojiLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.left.equalTo(self.containerView).offset(16)
        }
        
        self.messageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.emojiLabel)
            make.left.equalTo(self.emojiLabel.snp.right).offset(8)
        }
        
        self.countLabel.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.containerView).offset(21)
            make.bottom.equalTo(self.containerView).offset(-21)
            make.height.equalTo(26)
        }
    }
}
