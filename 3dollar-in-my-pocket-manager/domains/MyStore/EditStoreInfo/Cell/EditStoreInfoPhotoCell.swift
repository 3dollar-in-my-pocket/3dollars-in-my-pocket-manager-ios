import UIKit

final class EditStoreInfoPhotoCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: 76, height: 76)
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "ic_delete_without_padding")?.resizeImage(scaledTo: 16)
        button.setImage(image, for: .normal)
        return button
    }()
    
    override func setup() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.size.equalTo(72)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.top.equalTo(imageView).offset(-4)
            $0.trailing.equalTo(imageView).offset(4)
        }
    }
    
    func bind(_ bossStoreInmage: BossStoreImage, isLastOne: Bool) {
        if let imageUrl = bossStoreInmage.imageUrl {
            imageView.setImage(urlString: imageUrl)
        } else if let image = bossStoreInmage.image {
            imageView.image = image
        }
        deleteButton.isHidden = isLastOne
    }
}
