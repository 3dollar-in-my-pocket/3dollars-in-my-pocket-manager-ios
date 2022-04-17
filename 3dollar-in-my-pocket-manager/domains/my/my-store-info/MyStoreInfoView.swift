import UIKit

final class MyStoreInfoView: BaseView {
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(477)
            ))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(477)
            ), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            return section
//            if sectionIndex == 0 {
//
//            } else {
//                return
//            }
        }
        
        $0.collectionViewLayout = layout
        $0.register(
            MyStoreInfoOverviewCell.self,
            forCellWithReuseIdentifier: MyStoreInfoOverviewCell.registerId
        )
    }
    
    override func setup() {
        self.addSubViews([
            self.collectionView
        ])
    }
    
    override func bindConstraints() {
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
