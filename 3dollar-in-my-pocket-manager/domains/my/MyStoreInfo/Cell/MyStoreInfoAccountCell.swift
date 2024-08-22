import UIKit

final class MyStoreInfoAccountCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 72
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let textLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .gray95
        $0.numberOfLines = 0
    }
    
    override func setup() {
        containerView.backgroundColor = .white
        contentView.addSubViews([
            containerView,
            textLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(16)
            $0.trailing.equalTo(containerView).offset(-16)
            $0.bottom.equalTo(containerView).offset(-16)
        }
    }
    
    func bind(accountInfos: [BossStoreAccountNumber]) {
        if let accountInfo = accountInfos.first {
            textLabel.text = "\(accountInfo.bank.description) \(accountInfo.accountNumber)"
            textLabel.textColor = .gray95
        } else {
            textLabel.text = "my_store_info_account_empty_placeholder".localized
            textLabel.textColor = .gray40
            textLabel.setLineHeight(lineHeight: 20)
        }
    }
}
