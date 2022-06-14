import UIKit

import RxSwift
import RxCocoa

final class MyStoreInfoView: BaseView {
    fileprivate let refreshControl = UIRefreshControl()
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoOverviewCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoOverviewCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else if sectionIndex == 1 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoIntroductionCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoIntroductionCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            } else if sectionIndex == 2 {
                let menuItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoMenuCell.height)
                ))
                let moreItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoMenuMoreCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoMenuCell.height)
                ), subitems: [menuItem, moreItem])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoWorkDayCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoWorkDayCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            }
        }
        
        $0.collectionViewLayout = layout
        $0.backgroundColor = .gray0
        $0.register(
            MyStoreInfoOverviewCell.self,
            forCellWithReuseIdentifier: MyStoreInfoOverviewCell.registerId
        )
        $0.register(
            MyStoreInfoIntroductionCell.self,
            forCellWithReuseIdentifier: MyStoreInfoIntroductionCell.registerId
        )
        $0.register(
            MyStoreInfoMenuCell.self,
            forCellWithReuseIdentifier: MyStoreInfoMenuCell.registerId
        )
        $0.register(
            MyStoreInfoMenuMoreCell.self,
            forCellWithReuseIdentifier: MyStoreInfoMenuMoreCell.registerId
        )
        $0.register(
            MyStoreInfoWorkDayCell.self,
            forCellWithReuseIdentifier: MyStoreInfoWorkDayCell.registerId
        )
        $0.register(
            MyStoreInfoHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MyStoreInfoHeaderView.registerId
        )
    }
    
    override func setup() {
        self.collectionView.refreshControl = self.refreshControl
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

extension Reactive where Base: MyStoreInfoView {
    var pullToRefresh: ControlEvent<Void> {
        return ControlEvent(events: base.refreshControl.rx.controlEvent(.valueChanged)
            .map { _ in () })
        
    }
    
    var endRefreshing: Binder<Void> {
        return Binder(self.base) { view, _ in
            view.refreshControl.endRefreshing()
        }
    }
}
