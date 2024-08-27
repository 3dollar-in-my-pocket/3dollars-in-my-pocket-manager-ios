import UIKit

final class MyStoreInfoAccountCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 72
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let textLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .gray95
        $0.numberOfLines = 0
    }
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray30
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray95
        label.numberOfLines = 0
        return label
    }()
    
    override func setup() {
        containerView.backgroundColor = .white
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(dividerView)
        stackView.addArrangedSubview(nameLabel)
        contentView.addSubViews([
            containerView,
            stackView
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(16)
            $0.trailing.equalTo(containerView).offset(-16)
            $0.bottom.equalTo(containerView).offset(-16)
        }
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(12)
            $0.width.equalTo(1)
        }
    }
    
    func bind(accountInfos: [BossStoreAccountNumber]) {
        if let accountInfo = accountInfos.first {
            textLabel.text = "\(accountInfo.bank.description) \(accountInfo.accountNumber)"
            textLabel.textColor = .gray95
            nameLabel.text = accountInfo.accountHolder
        } else {
            textLabel.text = "my_store_info_account_empty_placeholder".localized
            textLabel.textColor = .gray40
            textLabel.setLineHeight(lineHeight: 20)
        }
    }
}
