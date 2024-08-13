import UIKit

final class EditStoreInfoPhotoView: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray100
        label.text = "signup_photo_title".localized
        return label
    }()
    
    private let redDot: UIView = {
        let view = UIView()
        view.backgroundColor = .pink
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: <#T##UICollectionViewLayout#>)
    }()
}


