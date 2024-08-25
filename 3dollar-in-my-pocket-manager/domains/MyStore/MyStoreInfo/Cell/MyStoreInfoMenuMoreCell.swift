import UIKit

final class MyStoreInfoMenuMoreCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 48
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray40
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -8
        return stackView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        addSubViews([
            containerView,
            titleLabel,
            stackView
        ])
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(4)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.centerY.equalTo(containerView)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.right.equalTo(containerView).offset(-16)
        }
    }
    
    func bind(menus: [BossStoreMenu]) {
        titleLabel.text = String.init(
            format: "my_store_info_menu_more_format".localized,
            menus.count
        )
        
        for menu in menus {
            let photoView = generatePhotoView(menu: menu)
            
            stackView.addArrangedSubview(photoView)
        }
    }
    
    private func generatePhotoView(menu: BossStoreMenu) -> UIImageView {
        let photoView = UIImageView()
        
        photoView.layer.cornerRadius = 14
        photoView.layer.masksToBounds = true
        if let image = menu.image {
            photoView.setImage(image)
        }
        photoView.snp.makeConstraints { make in
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        return photoView
    }
}
