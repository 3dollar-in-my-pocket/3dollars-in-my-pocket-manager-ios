import UIKit

struct ReviewListSection: Hashable {
    let type: ReviewListSectionType
    let items: [ReviewListSectionItem]
}

enum ReviewListSectionType: Hashable {
    case overview
    case reviewList(ReviewSortType)
}

enum ReviewListSectionItem: Hashable {
    case overview(totalReviewCount: Int, rating: Double)
    case review(ReviewListItemCellViewModel)
}

final class ReviewListDataSource: UICollectionViewDiffableDataSource<ReviewListSection, ReviewListSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ReviewListSection, ReviewListSectionItem>
    
    init(collectionView: UICollectionView, viewModel: ReviewListViewModel) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview(let count, let rating):
                let cell: ReviewOverviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(count: count, rating: rating)
                return cell
            case .review(let viewModel):
                let cell: ReviewListItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            if let sectionType = self?.sectionIdentifier(section: indexPath.section)?.type,
               case .reviewList(let sortType) = sectionType,
               kind == UICollectionView.elementKindSectionHeader {
                let header: ReviewListHeaderView = collectionView.dequeueReusableHeader(indexPath: indexPath)
                header.bind(sortType: sortType)
                header.didTapSortButton
                    .subscribe(viewModel.input.didTapSortType)
                    .store(in: &header.cancellables)
                return header
            } else {
                return nil
            }
        }
        
        collectionView.register([
            ReviewOverviewCell.self,
            ReviewListItemCell.self
        ])
        collectionView.registerHeader(ReviewListHeaderView.self)
    }
    
    func reload(_ sections: [ReviewListSection]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot)
    }
}
