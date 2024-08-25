import UIKit

final class MyStoreInfoMenuCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 86
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray95
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 14)
        label.textColor = .gray95
        return label
    }()
    
    private let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func setup() {
        backgroundColor = .clear
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)
        addSubViews([
            containerView,
            stackView,
            photoView
        ])
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.centerY.equalTo(containerView)
            make.right.equalTo(photoView.snp.left).offset(-40)
        }
        
        photoView.snp.makeConstraints { make in
            make.right.equalTo(containerView).offset(-16)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalTo(containerView)
        }
    }
    
    func bind(menu: BossStoreMenu) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let price = numberFormatter.string(for: menu.price)

        
        nameLabel.text = menu.name
        priceLabel.text = price
        if let image = menu.image {
            photoView.setImage(image)
        }
    }
}
