import UIKit

final class MessageBookmarkCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 320
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Assets.imgMessageBookmark.image
        return imageView
    }()
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
