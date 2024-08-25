import UIKit

final class MyStoreInfoMenuEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 52
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray40
        label.font = .regular(size: 14)
        label.text = "my_store_info_menu_empty".localized
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_empty_menu")
        return imageView
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            titleLabel,
            imageView
        ])
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.height.equalTo(Layout.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.centerY.equalTo(containerView)
        }
        
        imageView.snp.makeConstraints { make in
            make.right.equalTo(containerView).offset(-16)
            make.centerY.equalTo(containerView)
            make.width.equalTo(32)
            make.width.equalTo(32)
        }
    }
}
