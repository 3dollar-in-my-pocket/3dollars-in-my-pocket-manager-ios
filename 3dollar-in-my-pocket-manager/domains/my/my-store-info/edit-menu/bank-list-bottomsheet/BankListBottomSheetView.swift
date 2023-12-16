import UIKit

final class BankListBottomSheetView: BaseView {
    enum Layout {
        static let itemSpace: CGFloat = 8
        static let lineSpace: CGFloat = 6
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 20)
        $0.textColor = .gray100
        $0.text = "은행 선택"
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close_circle"), for: .normal)
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    override func setup() {
        backgroundColor = .white
        collectionView.register([BankListCell.self])
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 20, right: 20)
        
        addSubViews([
            titleLabel,
            closeButton,
            collectionView
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(24)
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
