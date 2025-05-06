import UIKit

struct StatisticsSection: Hashable {
    let type: StatisticsSectionType
    let items: [StatisticsSectionItem]
}

enum StatisticsSectionType: Hashable {
    case bookmark
    case feedback
    case review(totalReviewCount: Int, rating: Double)
}

enum StatisticsSectionItem: Hashable {
    case bookmarkCount(StatisticsBookmarkCountCellViewModel)
    case feedback(StatisticsFeedbackCountCellViewModel)
    case emptyReview
    case review(ReviewItemViewModel)
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
            case .feedback(let viewModel):
                let cell: StatisticsFeedbackCountCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            case .emptyReview:
                let cell: StatisticsReviewEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            case .review(let viewModel):
                if viewModel.output.review.status == .filtered {
                    let cell: StatisticsReviewReportedCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                    cell.bind(viewModel.output.review)
                    return cell
                } else {
                    let cell: StatisticsReviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                    cell.bind(viewModel: viewModel)
                    return cell
                }
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard
                let self,
                let section = sectionIdentifier(section: indexPath.section),
                case .review(let totalReviewCount, let rating) = section.type
            else { return UICollectionReusableView() }

            if kind == UICollectionView.elementKindSectionHeader {
                let headerView: StatisticsReviewHeaderView = collectionView.dequeueReusableHeader(indexPath: indexPath)
                headerView.bind(count: totalReviewCount, rating: rating)
                return headerView
            } else if kind == UICollectionView.elementKindSectionFooter && section.items.isNotEmpty {
                let footerView: StatisticsReviewFooterView = collectionView.dequeueReusableFooter(indexPath: indexPath)
                footerView.totalReviewButton.tapPublisher
                    .throttleClick()
                    .subscribe(viewModel.input.didTapMoreReview)
                    .store(in: &footerView.cancellables)
                return footerView
            }
            
            return nil
        }
        
        collectionView.register([
            StatisticsBookmarkCountCell.self,
            StatisticsFeedbackCountCell.self,
            StatisticsReviewEmptyCell.self,
            StatisticsReviewCell.self,
            StatisticsReviewReportedCell.self
        ])
        collectionView.registerHeader(StatisticsReviewHeaderView.self)
        collectionView.registerHeader(UICollectionReusableView.self)
        collectionView.registerFooter(StatisticsReviewFooterView.self)
        collectionView.registerFooter(UICollectionReusableView.self)
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
