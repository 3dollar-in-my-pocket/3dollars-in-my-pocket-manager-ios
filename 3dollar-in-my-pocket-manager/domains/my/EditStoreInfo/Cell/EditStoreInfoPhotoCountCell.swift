import UIKit

final class EditStoreInfoPhotoCountCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: 72, height: 72)
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private let cameraImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_camera")?
            .resizeImage(scaledTo: 28)
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.gray30)
        return imageView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 12)
        label.textColor = .gray40
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        contentView.backgroundColor = .gray5
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        stackView.addArrangedSubview(cameraImage)
        cameraImage.snp.makeConstraints {
            $0.size.equalTo(28)
        }
        
        stackView.addArrangedSubview(countLabel)
    }
}
