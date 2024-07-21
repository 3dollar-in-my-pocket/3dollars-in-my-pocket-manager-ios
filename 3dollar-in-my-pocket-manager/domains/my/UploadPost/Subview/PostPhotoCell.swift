import UIKit

final class PostPhotoCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: 84, height: 84)
    }
    
    var didTapDelete: (() -> Void)? = nil
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray5
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_delete"), for: .normal)
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        didTapDelete = nil
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
    }
    
    func bind(imageContent: ImageContent, didTapDelete: (() -> Void)? = nil) {
        self.didTapDelete = didTapDelete
        if let image = imageContent.image {
            imageView.image = image
        } else if let url = imageContent.url {
            imageView.setImage(urlString: url)
        }
    }
    
    override func setup() {
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4)
            $0.top.equalToSuperview().offset(4)
        }
        
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalTo(imageView).offset(-12)
            $0.trailing.equalTo(imageView).offset(12)
        }
    }
    
    @objc private func didTapDeleteButton() {
        didTapDelete?()
    }
}
