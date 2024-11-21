import UIKit

final class MessageDisableToastCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 44
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray90
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = Assets.icInformation.image
            .resizeImage(scaledTo: 20)
            .withRenderingMode(.alwaysTemplate)
        icon.tintColor = .white
        return icon
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = Strings.Message.Overview.disableToast
        label.font = .medium(size: 12)
        label.textColor = .white
        return label
    }()

    override func setup() {
        contentView.addSubview(containerView)
        containerView.addSubViews([
            icon,
            label
        ])
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.centerY.equalTo(icon)
            $0.leading.equalTo(icon.snp.trailing).offset(4)
        }
    }
}
