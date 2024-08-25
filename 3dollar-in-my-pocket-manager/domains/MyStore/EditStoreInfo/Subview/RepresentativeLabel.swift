import UIKit

final class RepresentativeLabel: BaseView {
    enum Layout {
        static let size = CGSize(width: 40, height: 18)
    }
    
    private let checkImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_check_line")?
            .resizeImage(scaledTo: 12)
            .withRenderingMode(.alwaysTemplate)
        
        imageView.image = image
        imageView.tintColor = .gray40
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 10)
        label.textColor = .gray40
        label.text = "edit_store_info.photo.representative".localized
        return label
    }()
    
    override func setup() {
        backgroundColor = .black
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addSubview(checkImage)
        checkImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(12)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkImage.snp.trailing).offset(2)
            $0.centerY.equalToSuperview()
        }
        
        snp.makeConstraints {
            $0.size.equalTo(Layout.size)
        }
    }
}
