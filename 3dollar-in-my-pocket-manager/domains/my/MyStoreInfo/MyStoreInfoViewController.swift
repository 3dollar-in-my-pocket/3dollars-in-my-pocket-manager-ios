import UIKit

final class MyStoreInfoViewController: BaseViewController {
    override var screenName: ScreenName {
        return .myStoreInfo
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
        
        collectionView.backgroundColor = .gray0
        return collectionView
    }()
    
    private let refreshControl = UIRefreshControl()
    private let viewModel: MyStoreInfoViewModel
    private lazy var dataSource = MyStoreInfoDataSource(collectionView: collectionView, viewModel: viewModel)
    private var isRefreshing = false
    
    init(viewModel: MyStoreInfoViewModel = MyStoreInfoViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        viewModel.input.load.send(())
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
    }
    
    private func bind() {
        refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        // Bind output
        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewController, sections: [MyStoreInfoSection]) in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.isRefreshing
            .filter { $0.isNot }
            .main
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewController, _) in
                owner.refreshControl.endRefreshing()
                owner.isRefreshing = false
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewController, route: MyStoreInfoViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self,
                  let sectionType = dataSource.sectionIdentifier(section: sectionIndex)?.type else {
                fatalError("정의되지 않은 섹션입니다.")
            }
            
            switch sectionType {
            case .overview:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoOverviewCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoOverviewCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            case .introduction:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoIntroductionCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoIntroductionCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            case .menu:
                let menuItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoMenuCell.Layout.height)
                ))
                let moreItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoMenuMoreCell.Layout.height)
                ))
                let emptyItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyStoreInfoMenuEmptyCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoMenuCell.Layout.height)
                ), subitems: [menuItem, moreItem, emptyItem])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            case .account:
                let accountItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoAccountCell.Layout.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoAccountCell.Layout.estimatedHeight)
                ), subitems: [accountItem])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            case .appearanceDay:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoWorkDayCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MyStoreInfoWorkDayCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyStoreInfoHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                return section
            }
        }
    }
    
    private func handleRoute(_ route: MyStoreInfoViewModel.Route) {
        switch route {
        case .pushEditStoreInfo(let viewModel):
            let viewController = EditStoreInfoViewController(viewModel: viewModel)
            
            parent?.navigationController?.pushViewController(viewController, animated: true)
        case .pushEditIntroduction(let viewModel):
            let viewController = EditIntroductionViewController(viewModel: viewModel)
            
            parent?.navigationController?.pushViewController(viewController, animated: true)
        case .pushEditMenus(let viewModel):
            let viewController = EditMenuViewController(viewModel: viewModel)
            
            parent?.navigationController?.pushViewController(viewController, animated: true)
        case .pushEditAccount(let viewModel):
            let viewController = EditAccountViewController(viewModel: viewModel)
            
            parent?.navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
}

extension MyStoreInfoViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard isRefreshing else  { return }
        
        viewModel.input.refresh.send(())
    }
}
