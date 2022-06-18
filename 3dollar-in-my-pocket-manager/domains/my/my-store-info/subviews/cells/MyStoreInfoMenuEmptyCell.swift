import UIKit

final class MyStoreInfoMenuEmptyCell: BaseCollectionViewCell {
    static let registerId = "\(MyStoreInfoMenuEmptyCell.self)"
    static let height: CGFloat = 52
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray40
        $0.font = .regular(size: 14)
        $0.text = "my_store_info_menu_empty".localized
    }
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "img_empty_menu")
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.titleLabel,
            self.imageView
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.height.equalTo(Self.height)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.centerY.equalTo(self.containerView)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-16)
            make.centerY.equalTo(self.containerView)
            make.width.equalTo(32)
            make.width.equalTo(32)
        }
    }
}
