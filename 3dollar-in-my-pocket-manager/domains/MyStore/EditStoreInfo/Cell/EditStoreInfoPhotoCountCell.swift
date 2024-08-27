import UIKit

final class EditStoreInfoPhotoCountCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: 76, height: 76)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 16
        return view
    }()
    
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
        imageView.tintColor = .gray30
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
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.size.equalTo(72)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        stackView.addArrangedSubview(cameraImage)
        cameraImage.snp.makeConstraints {
            $0.size.equalTo(28)
        }
        
        stackView.addArrangedSubview(countLabel)
    }
    
    func bind(count: Int) {
        let string = "\(count)/10"
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: "\(count)")
        attributedString.addAttribute(.foregroundColor, value: UIColor.green, range: range)
        
        countLabel.attributedText = attributedString
    }
}
