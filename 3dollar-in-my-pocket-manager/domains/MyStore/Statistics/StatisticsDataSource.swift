import UIKit

struct StatisticsSection: Hashable {
    let type: StatisticsSectionType
    let items: [StatisticsSectionItem]
}

enum StatisticsSectionType: Hashable {
    case bookmark
    case feedback
    case review
}

enum StatisticsSectionItem: Hashable {
    case bookmarkCount(StatisticsBookmarkCountCellViewModel)
}


final class StatisticsDataSource: UICollectionViewDiffableDataSource<StatisticsSection, StatisticsSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<StatisticsSection, StatisticsSectionItem>
    
    init(collectionView: UICollectionView, viewModel: StatisticsViewModel) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .bookmarkCount(let viewModel):
                let cell: StatisticsBookmarkCountCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            }
        }
        
        collectionView.register([
            StatisticsBookmarkCountCell.self
        ])
    }
    
    func reload(_ sections: [StatisticsSection]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot)
    }
}
