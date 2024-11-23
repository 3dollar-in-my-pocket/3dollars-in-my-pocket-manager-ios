import UIKit

struct MessageSection: Hashable {
    enum SectionType {
        case first
        case overview
    }
    
    let type: SectionType
    let items: [MessageSectionItem]
}

enum MessageSectionItem: Hashable {
    case overview
    case toast
    case firstTitle
    case bookmark
    case introduction
}

final class MessageDataSource: UICollectionViewDiffableDataSource<MessageSection, MessageSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<MessageSection, MessageSectionItem>
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview:
                let cell: MessageOverviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                return cell
            case .toast:
                let cell: MessageDisableToastCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                return cell
            case .firstTitle:
                let cell: MessageFirstTitleCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                return cell
            case .bookmark:
                let cell: MessageBookmarkCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                return cell
            case .introduction:
                let cell: MessageIntroductionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                return cell
            }
        }
        
        collectionView.register([
            MessageOverviewCell.self,
            MessageDisableToastCell.self,
            MessageFirstTitleCell.self,
            MessageBookmarkCell.self,
            MessageIntroductionCell.self
        ])
    }
    
    func reload(_ sections: [MessageSection]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}
