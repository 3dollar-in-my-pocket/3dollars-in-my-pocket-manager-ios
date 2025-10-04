import UIKit

struct AISection: Hashable {
    var items: [AISectionItem]
}

enum AISectionItem: Hashable {
    case speechBubble(SpeechBubbleCellViewModel)
    case recommendation(AIResponseCellViewModel)
    case loading
    case error(AIErrorCellViewModel)
}

final class AIDatasource: UICollectionViewDiffableDataSource<AISection, AISectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AISection, AISectionItem>
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .speechBubble(let viewModel):
                let cell: SpeechBubbleCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            case .recommendation(let viewModel):
                let cell: AIResponseCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            case .loading:
                let cell: LoadingCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            case .error(let viewModel):
                let cell: AIErrorCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            }
        }
        
        collectionView.register([
            SpeechBubbleCell.self,
            AIResponseCell.self,
            LoadingCell.self,
            AIErrorCell.self,
            BaseCollectionViewCell.self
        ])
    }
    
    func reload(_ sections: [AISection]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}
