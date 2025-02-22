import UIKit

final class CommentPresetBottomSheet: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.text = "자주 쓰는 문구"
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icDeleteX.image, for: .normal)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 24
        layout.itemSize = .zero
        return layout
    }
}
