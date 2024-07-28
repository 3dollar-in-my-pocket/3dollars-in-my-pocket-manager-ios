import UIKit

import ReactorKit
import RxDataSources

final class MyStoreInfoViewController: BaseViewController, View, MyStoreInfoCoordinator {
    private let myStoreInfoView = MyStoreInfoView()
    private let myStoreInfoReactor = MyStoreInfoReactor(
        storeService: StoreService(),
        globalState: GlobalState.shared,
        logManager: .shared
    )
    private weak var coordinator: MyStoreInfoCoordinator?
    private var myStoreInfoCollectionViewDataSource
    : RxCollectionViewSectionedReloadDataSource<MyStoreInfoSectionModel>!
    private var isRefreshing = false
    override var screenName: ScreenName {
        return .myStoreInfo
    }
    
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
        super.viewDidLoad()
        
        self.setupDataSource()
        self.coordinator = self
        self.myStoreInfoView.collectionView.delegate = self
        self.reactor = self.myStoreInfoReactor
        self.myStoreInfoReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.myStoreInfoView.rx.pullToRefresh
            .bind(onNext: { [weak self] _ in
                self?.isRefreshing = true
            })
            .disposed(by: self.eventDisposeBag)
        
        self.myStoreInfoReactor.pushEditStoreInfoPublisher
            .asDriver(onErrorJustReturn: Store())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.pushEditStoreInfo(store: store)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.myStoreInfoReactor.pushEditIntroductionPublisher
            .asDriver(onErrorJustReturn: Store())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.pushEditIntroduction(store: store)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.myStoreInfoReactor.pushEditMenuPublisher
            .asDriver(onErrorJustReturn: Store())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.pushEditMenu(store: store)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.myStoreInfoReactor.pushEditSchedulePublisher
            .asDriver(onErrorJustReturn: Store())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.pushEditSchedule(store: store)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: MyStoreInfoReactor) {
        // Bind state
        reactor.state
            .map { [
                .overview($0.store),
                .introduction($0.store.introduction),
                .menus($0.store.menus),
                .account($0.store.accountInfos),
                .appearanceDays($0.store.appearanceDays)
            ] }
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                self?.myStoreInfoView.rx.endRefreshing.onNext(())
            })
            .asDriver(onErrorJustReturn: [])
            .delay(.milliseconds(500))
            .drive(self.myStoreInfoView.collectionView.rx.items(
                dataSource: self.myStoreInfoCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .bind { [weak self] route in
                self?.handleRoute(route)
            }
            .disposed(by: disposeBag)
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
                    collectionView
                        .rx.contentOffset
                        .map { $0.y }
                        .bind(onNext: {
                            cell.bindPhotoConstraintAgain(height: $0)
                        })
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
                        withReuseIdentifier: MyStoreInfoMenuCell.registerId,
                        for: indexPath
                    ) as? MyStoreInfoMenuCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(menu: menu)
                    return cell
                    
                case .menuMore(let menus):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyStoreInfoMenuMoreCell.registerId,
                        for: indexPath
                    ) as? MyStoreInfoMenuMoreCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(menus: menus)
                    return cell
                    
                case .emptyMenu:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyStoreInfoMenuEmptyCell.registerId,
                        for: indexPath
                    ) as? MyStoreInfoMenuEmptyCell else { return BaseCollectionViewCell() }
                    
                    return cell
                    
                case .appearanceDay(let appearanceDay):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyStoreInfoWorkDayCell.registerId,
                        for: indexPath
                    ) as? MyStoreInfoWorkDayCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(appearanceDay: appearanceDay)
                    return cell
                    
                case .account(let accountInfo):
                    let cell: MyStoreInfoAccountCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                    
                    cell.bind(accountInfo: accountInfo)
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
                
                if indexPath.section == 1 {
                    headerView.titleLabel.text
                    = "my_store_info_header_introduction".localized
                    headerView.rightButton.setTitle(
                        "my_store_info_header_introduction_button".localized,
                        for: .normal
                    )
                    headerView.rx.tapRightButton
                        .map { Reactor.Action.tapEditIntroduction }
                        .bind(to: self.myStoreInfoReactor.action)
                        .disposed(by: headerView.disposeBag)
                } else if indexPath.section == 2 {
                    headerView.titleLabel.text = "my_store_info_header_menus".localized
                    headerView.rightButton.setTitle(
                        "my_store_info_header_menus_button".localized,
                        for: .normal
                    )
                    headerView.rx.tapRightButton
                        .map { Reactor.Action.tapEditMenus }
                        .bind(to: self.myStoreInfoReactor.action)
                        .disposed(by: headerView.disposeBag)
                } else if indexPath.section == 3 {
                    headerView.titleLabel.text = "my_store_info_header_account".localized
                    headerView.rightButton.setTitle(
                        "my_store_info_header_account_button".localized,
                        for: .normal
                    )
                    
                    headerView.rx.tapRightButton
                        .map { Reactor.Action.tapEditAccount }
                        .bind(to: self.myStoreInfoReactor.action)
                        .disposed(by: headerView.disposeBag)
                } else {
                    headerView.titleLabel.text = "my_store_info_header_appearance_day".localized
                    headerView.rightButton.setTitle(
                        "my_store_info_header_appearance_day_button".localized,
                        for: .normal
                    )
                    headerView.rx.tapRightButton
                        .map { Reactor.Action.tapEditSchedule }
                        .bind(to: self.myStoreInfoReactor.action)
                        .disposed(by: headerView.disposeBag)
                }
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
    
    private func handleRoute(_ route: MyStoreInfoReactor.Route) {
        switch route {
        case .pushEditAccount(let reactor):
            coordinator?.pushEditAccount(reactor: reactor)
        }
    }
}

extension MyStoreInfoViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.isRefreshing {
            self.myStoreInfoReactor.action.onNext(.refresh)
            self.isRefreshing = false
        }
    }
}
