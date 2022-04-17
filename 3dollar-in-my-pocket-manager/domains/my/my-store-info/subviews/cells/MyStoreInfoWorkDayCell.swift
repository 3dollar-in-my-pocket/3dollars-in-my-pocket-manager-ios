import UIKit

final class MyStoreInfoWorkDayCell: BaseCollectionViewCell {
    static let registerId = "\(MyStoreInfoWorkDayCell.self)"
    static let height: CGFloat = 86
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let weekDayLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = .gray95
        $0.text = "월요일"
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = .gray70
        $0.text = "15:00 - 20:00"
        $0.textAlignment = .right
    }
    
    private let locationLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .gray70
        $0.text = "서울특별시 강남역 0번 출구"
        $0.textAlignment = .right
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.weekDayLabel,
            self.timeLabel,
            self.locationLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        self.weekDayLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
        }
        
        self.timeLabel.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.weekDayLabel)
        }
        
        self.locationLabel.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.timeLabel.snp.bottom).offset(2)
        }
    }
}
