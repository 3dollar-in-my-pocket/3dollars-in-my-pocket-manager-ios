import UIKit

final class EditStoreInfoPhotoCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: 72, height: 72)
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
        let image = UIImage(named: "ic_delete")?.resizeImage(scaledTo: 16)
        button.setImage(image, for: .normal)
        return button
    }()
    
    override func setup() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.top.equalTo(imageView).offset(-4)
            $0.trailing.equalTo(imageView).offset(-4)
        }
    }
    
    func bind(imageResponse: ImageResponse) {
        imageView.setImage(urlString: imageResponse.imageUrl)
    }
}
