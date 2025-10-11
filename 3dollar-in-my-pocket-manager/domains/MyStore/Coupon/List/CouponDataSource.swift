import UIKit

struct CouponSection: Hashable {
    enum SectionType {
        case empty
        case coupon
    }
    
    let type: SectionType
    let items: [CouponSectionItem]
}

enum CouponSectionItem: Hashable {
    case empty
    case coupon(CouponItemCellViewModel)
}

final class CouponDataSource: UICollectionViewDiffableDataSource<CouponSection, CouponSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<CouponSection, CouponSectionItem>
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .empty:
                let cell: CouponEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            case .coupon(let viewModel):
                let cell: CouponItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            }
        }
        
        collectionView.register([CouponEmptyCell.self, CouponItemCell.self])
    }
    
    func reload(_ sections: [CouponSection]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}
