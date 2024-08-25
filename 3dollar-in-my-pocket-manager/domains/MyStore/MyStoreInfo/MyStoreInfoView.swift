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
                    heightDimension: .absolute(MyStoreInfoOverviewCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoOverviewCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else if sectionIndex == 1 {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoIntroductionCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoIntroductionCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            } else if sectionIndex == 2 {
                let menuItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoMenuCell.Layout.height)
                ))
                let moreItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoMenuMoreCell.Layout.height)
                ))
                let emptyItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoMenuEmptyCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoMenuCell.Layout.height)
                ), subitems: [menuItem, moreItem, emptyItem])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            } else if sectionIndex == 3 {
                let accountItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoAccountCell.Layout.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoAccountCell.Layout.estimatedHeight)
                ), subitems: [accountItem])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoWorkDayCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoWorkDayCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            }
        }
        
        $0.collectionViewLayout = layout
        $0.backgroundColor = .gray0
        $0.register([
            MyStoreInfoOverviewCell.self,
            MyStoreInfoIntroductionCell.self,
            MyStoreInfoMenuCell.self,
            MyStoreInfoMenuMoreCell.self,
            MyStoreInfoMenuEmptyCell.self,
            MyStoreInfoWorkDayCell.self,
            MyStoreInfoAccountCell.self,
        ])
        
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
