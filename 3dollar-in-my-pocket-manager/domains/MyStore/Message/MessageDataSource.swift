import UIKit

struct MessageSection: Hashable {
    enum SectionType {
        case first
        case noHistory
        case overview
        case message
    }
    
    let type: SectionType
    let items: [MessageSectionItem]
}

enum MessageSectionItem: Hashable {
    case overview(subscriberCount: Int)
    case toast
    case firstTitle
    case bookmark
    case introduction
    case message(StoreMessageResponse)
}

final class MessageDataSource: UICollectionViewDiffableDataSource<MessageSection, MessageSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<MessageSection, MessageSectionItem>
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview(let subscriberCount):
                let cell: MessageOverviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(count: subscriberCount)
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
            case .message(let message):
                let cell: MessageHistoryCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(message: message)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let self,
                  let section = sectionIdentifier(section: indexPath.section),
                  section.type == .message else { return nil }
            
            let headerView: MessageHistoryHeaderView = collectionView.dequeueReusableHeader(indexPath: indexPath)
            return headerView
        }
        
        collectionView.register([
            MessageOverviewCell.self,
            MessageDisableToastCell.self,
            MessageFirstTitleCell.self,
            MessageBookmarkCell.self,
            MessageIntroductionCell.self,
            MessageHistoryCell.self
        ])
        collectionView.registerHeader(MessageHistoryHeaderView.self)
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
