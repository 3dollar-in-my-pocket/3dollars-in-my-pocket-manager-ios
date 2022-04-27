import UIKit

import ReactorKit
import RxDataSources

final class MyStoreInfoViewController: BaseViewController, View, MyStoreInfoCoordinator {
    private let myStoreInfoView = MyStoreInfoView()
    private let myStoreInfoReactor = MyStoreInfoReactor(storeService: StoreService())
    private weak var coordinator: MyStoreInfoCoordinator?
    private var myStoreInfoCollectionViewDataSource
    : RxCollectionViewSectionedReloadDataSource<MyStoreInfoSectionModel>!
    
    static func instance() -> UINavigationController {
        let viewController = MyStoreInfoViewController(nibName: nil, bundle: nil)
        
        return UINavigationController(rootViewController: viewController).then {
            $0.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func loadView() {
        self.view = self.myStoreInfoView
    }
    
    override func viewDidLoad() {
        self.setupDataSource()
        self.coordinator = self
        self.reactor = self.myStoreInfoReactor
        self.myStoreInfoReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.myStoreInfoReactor.pushEditStoreInfoPublisher
            .asDriver(onErrorJustReturn: Store())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.pushEditStoreInfo(store: store)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: MyStoreInfoReactor) {
        // Bind state
        reactor.state
            .map { [
                MyStoreInfoSectionModel(store: $0.store),
                MyStoreInfoSectionModel(introduction: $0.store.introduction),
                MyStoreInfoSectionModel(menus: $0.store.menus)
            ] }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.myStoreInfoView.collectionView.rx.items(
                dataSource: self.myStoreInfoCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.myStoreInfoCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource<MyStoreInfoSectionModel>(
            configureCell: { dataSource, collectionView, indexPath, item in
                switch item {
                case .overview(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyStoreInfoOverviewCell.registerId,
                        for: indexPath
                    ) as? MyStoreInfoOverviewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    cell.editButton.rx.tap
                        .map { Reactor.Action.tapEditStoreInfo }
                        .bind(to: self.myStoreInfoReactor.action)
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .introduction(let introduction):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyStoreInfoIntroductionCell.registerId,
                        for: indexPath
                    ) as? MyStoreInfoIntroductionCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(introduction: introduction)
                    return cell
                    
                case .menu(let menu):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyStoreInfoWorkDayCell.registerId,
                        for: indexPath
                    ) as? MyStoreInfoWorkDayCell else { return BaseCollectionViewCell() }
                    
                    return cell
                }
        })
        
        self.myStoreInfoCollectionViewDataSource.configureSupplementaryView
        = { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: MyStoreInfoHeaderView.registerId,
                    for: indexPath
                ) as? MyStoreInfoHeaderView else { return UICollectionReusableView() }
                
                headerView.rx.tapRightButton
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        let viewController = EditIntroductionViewController.instance(storeId: "", introduction: nil)
                        
                        self?.parent?.navigationController?.pushViewController(viewController, animated: true)
                    })
                    .disposed(by: headerView.disposeBag)
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}
