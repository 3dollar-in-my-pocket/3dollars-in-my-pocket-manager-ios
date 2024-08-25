import UIKit

final class BankListBottomSheetView: BaseView {
    enum Layout {
        static let itemSpace: CGFloat = 8
        static let lineSpace: CGFloat = 6
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.text = "은행 선택"
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_close_circle"), for: .normal)
        return button
    }()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    override func setup() {
        backgroundColor = .white
        collectionView.register([BankListCell.self])
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 20, right: 20)
        collectionView.backgroundColor = .white
        
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([
            titleLabel,
            closeButton,
            collectionView
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(24).priority(.high)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = BankListCell.Layout.size
        layout.minimumInteritemSpacing = Layout.itemSpace
        layout.minimumLineSpacing = Layout.lineSpace
        layout.scrollDirection = .vertical
        
        return layout
    }
}
