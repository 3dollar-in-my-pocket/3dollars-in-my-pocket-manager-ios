import UIKit

struct MessageSection: Hashable {
    enum SectionType {
        case overview
    }
    
    let type: SectionType
    let items: [MessageSectionItem]
}

enum MessageSectionItem: Hashable {
    case overview
}

final class MessageDataSource: UICollectionViewDiffableDataSource<MessageSection, MessageSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<MessageSection, MessageSectionItem>
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview:
                let cell: MessageOverviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                return cell
            }
        }
        
        collectionView.register([
            MessageOverviewCell.self
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
