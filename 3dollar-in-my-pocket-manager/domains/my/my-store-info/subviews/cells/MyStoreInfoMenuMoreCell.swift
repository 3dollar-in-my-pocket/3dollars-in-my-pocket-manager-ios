import UIKit

import Base

final class MyStoreInfoMenuMoreCell: BaseCollectionViewCell {
    static let registerId = "\(MyStoreInfoMenuMoreCell.self)"
    static let height: CGFloat = 48
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 16
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = .gray40
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = -8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.titleLabel,
            self.stackView
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(4)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.centerY.equalTo(self.containerView)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
        }
    }
    
    func bind(menus: [Menu]) {
        self.titleLabel.text = String.init(
            format: "my_store_info_menu_more_format".localized,
            menus.count
        )
        
        for menu in menus {
            let photoView = self.generatePhotoView(menu: menu)
            
            self.stackView.addArrangedSubview(photoView)
        }
    }
    
    private func generatePhotoView(menu: Menu) -> UIImageView {
        let photoView = UIImageView()
        
        photoView.layer.cornerRadius = 14
        photoView.layer.masksToBounds = true
        photoView.setImage(urlString: menu.imageUrl)
        photoView.snp.makeConstraints { make in
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        return photoView
    }
}
