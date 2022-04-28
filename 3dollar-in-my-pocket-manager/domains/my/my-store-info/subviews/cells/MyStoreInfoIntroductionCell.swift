import UIKit

final class MyStoreInfoIntroductionCell: BaseCollectionViewCell {
    static let registerId = "\(MyStoreInfoIntroductionCell.self)"
    static let height: CGFloat = 72
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let introductionLabel = UILabel().then {
        $0.textColor = .gray70
        $0.font = .regular(size: 14)
        $0.numberOfLines = 0
        $0.text = "손님들에게 하고 싶은 말을 적어주세요!\nex) 오전에 오시면 서비스가 있습니다!"
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.introductionLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.bottom.equalTo(self.introductionLabel).offset(16)
        }
        
        self.introductionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.containerView).offset(16)
        }
    }
    
    func bind(introduction: String?) {
        if let introduction = introduction {
            self.introductionLabel.text = introduction
        } else {
            self.introductionLabel.text = "my_store_info_introduction_placeholder".localized
        }
        
    }
}
