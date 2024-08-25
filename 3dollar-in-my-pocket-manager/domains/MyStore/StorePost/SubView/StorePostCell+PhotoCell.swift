import UIKit

extension StorePostCell {
    final class PhotoCell: BaseCollectionViewCell {
        enum Layout {
            static func calculateSize(ratio: Double) -> CGSize {
                return CGSize(width: ratio * height, height: height)
            }
            static let height: CGFloat = 208
        }
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 8
            imageView.backgroundColor = UIColor(r: 217, g: 217, b: 217)
            imageView.clipsToBounds = true
            return imageView
        }()
        
        override func prepareForReuse() {
            super.prepareForReuse()
            
            imageView.clear()
        }
        
        override func setup() {
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        func bind(_ imageUrl: String) {
            imageView.setImage(urlString: imageUrl)
        }
    }
}
