import UIKit

final class MyStoreInfoCollectionView: UICollectionView {
    init(dataSource: UICollectionViewDiffableDataSource<MyStoreInfoSection, MyStoreInfoSectionItem>) {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let sectionType = dataSource.sectionIdentifier(section: sectionIndex)?.type else {
                fatalError("정의되지 않은 섹션입니다.")
            }
            
            switch sectionType {
            case .overview:
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
            case .introduction:
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
            case .menu:
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
            case .account:
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
            case .appearanceDay:
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
        
        super.init(frame: .zero, collectionViewLayout: layout)
        backgroundColor = .gray0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

