import UIKit

final class UploadPhotoCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: 84, height: 84)
    }
    
    private let background: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let cameraIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_camera")?
            .withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = .gray30
        return imageView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray40
        label.font = .regular(size: 12)
        return label
    }()
    
    func bind(count: Int) {
        let countString = "\(count)/10"
        if count == 0 {
            countLabel.text = countString
        } else {
            let attributedString = NSMutableAttributedString(string: countString)
            let colorRange = NSString(string: countString).range(of: "\(count)")
            attributedString.addAttributes([
                .foregroundColor: UIColor.green,
                .font: UIFont.bold(size: 12) as Any
            ], range: colorRange)
            
            countLabel.attributedText = attributedString
        }
    }
    
    override func setup() {
        contentView.addSubview(background)
        background.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
        }
        
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(cameraIcon)
        stackView.addArrangedSubview(countLabel)
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.center.equalTo(background)
        }
        
        cameraIcon.snp.makeConstraints {
            $0.size.equalTo(28)
        }
        
        countLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
    }
}
