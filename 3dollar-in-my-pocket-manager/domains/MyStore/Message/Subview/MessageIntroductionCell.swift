import UIKit

final class MessageIntroductionCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 375
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Assets.imgMessageIntroduction.image
        return imageView
    }()
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
        }
    }
}
