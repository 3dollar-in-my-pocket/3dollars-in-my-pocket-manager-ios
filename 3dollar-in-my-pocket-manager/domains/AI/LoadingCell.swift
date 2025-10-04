import UIKit

final class LoadingCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 48)
    }
    
    private let indicator = UIActivityIndicatorView(style: .medium)
    
    override func setup() {
        overrideUserInterfaceStyle = .light
        contentView.addSubview(indicator)
        indicator.startAnimating()
    }
    
    override func bindConstraints() {
        indicator.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
        }
    }
}
