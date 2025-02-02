import UIKit

final class PhotoDetailCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(
            width: UIUtils.windowBounds.width,
            height: UIUtils.windowBounds.height - UIUtils.topSafeAreaInset - UIUtils.bottomSafeAreaInset - 116
        )
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0  // 최소 줌 배율
        scrollView.maximumZoomScale = 4.0  // 최대 줌 배율
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    
    override func setup() {
        super.setup()
        
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.size.equalTo(Layout.size)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.size.equalTo(Layout.size)
        }
    }
    
    func bind(imageUrl: String) {
        imageView.setImage(urlString: imageUrl)
    }
}

extension PhotoDetailCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
