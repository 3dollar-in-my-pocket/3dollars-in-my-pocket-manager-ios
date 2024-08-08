import UIKit

import CombineCocoa

struct MyStoreInfoSection: Hashable {
    enum SectionType: Hashable {
        case overview
        case introduction
        case menu
        case account
        case appearanceDay
    }
    
    var type: SectionType
    var items: [MyStoreInfoSectionItem]
}

enum MyStoreInfoSectionItem: Hashable {
    case overView(BossStoreInfoResponse)
    case introduction(String?)
    case menu(BossStoreMenuResponse)
    case menuMore([BossStoreMenuResponse])
    case emptyMenu
    case appearanceDay(BossStoreAppearanceDayResponse)
    case account([StoreAccountNumberResponse])
}


final class MyStoreInfoDataSource: UICollectionViewDiffableDataSource<MyStoreInfoSection, MyStoreInfoSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<MyStoreInfoSection, MyStoreInfoSectionItem>
    
    private let viewModel: MyStoreInfoViewModel
    
    init(collectionView: UICollectionView, viewModel: MyStoreInfoViewModel) {
        self.viewModel = viewModel
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overView(let store):
                let cell: MyStoreInfoOverviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(store: store)
                collectionView.contentOffsetPublisher
                    .map { $0.y }
                    .main
                    .withUnretained(collectionView)
                    .sink { (collectionView: UICollectionView, offset: CGFloat) in
                        cell.bindPhotoConstraintAgain(height: offset)
                    }
                    .store(in: &cell.cancellables)
                cell.editButton.tapPublisher
                    .map { _ in MyStoreInfoSection.SectionType.overview }
                    .subscribe(viewModel.input.didTapHeaderRightButton)
                    .store(in: &cell.cancellables)
                return cell
            case .introduction(let introduction):
                let cell: MyStoreInfoIntroductionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(introduction: introduction)
                return cell
            case .menu(let menu):
                let cell: MyStoreInfoMenuCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(menu: menu)
                return cell
            case .menuMore(let menus):
                let cell: MyStoreInfoMenuMoreCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(menus: menus)
                return cell
            case .emptyMenu:
                let cell: MyStoreInfoMenuEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                return cell
            case .appearanceDay(let appearanceDay):
                let cell: MyStoreInfoWorkDayCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(appearanceDay: appearanceDay)
                return cell
            case .account(let accountInfos):
                let cell: MyStoreInfoAccountCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(accountInfos: accountInfos)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self,
                  kind == UICollectionView.elementKindSectionHeader,
                  let sectionType = snapshot().sectionIdentifiers[safe: indexPath.section]?.type else { return UICollectionReusableView() }
            let headerView: MyStoreInfoHeaderView = collectionView.dequeueReusableHeader(indexPath: indexPath)
            
            headerView.bind(sectionType: sectionType)
            headerView.rightButton.tapPublisher
                .map { sectionType }
                .subscribe(viewModel.input.didTapHeaderRightButton)
                .store(in: &headerView.cancellables)
            return headerView
        }
        
        collectionView.register([
            MyStoreInfoOverviewCell.self,
            MyStoreInfoIntroductionCell.self,
            MyStoreInfoMenuCell.self,
            MyStoreInfoMenuMoreCell.self,
            MyStoreInfoMenuEmptyCell.self,
            MyStoreInfoWorkDayCell.self,
            MyStoreInfoAccountCell.self,
        ])
        collectionView.registerHeader(MyStoreInfoHeaderView.self)
        collectionView.registerHeader(UICollectionReusableView.self)
    }
    
    func reload(_ sections: [MyStoreInfoSection]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}
