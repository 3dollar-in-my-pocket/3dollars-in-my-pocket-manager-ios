import UIKit

import CombineCocoa

final class StatisticsViewController: BaseViewController {
    private let refreshControl = UIRefreshControl()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())

    private let viewModel: StatisticsViewModel
    private lazy var dataSource = StatisticsDataSource(collectionView: collectionView, viewModel: viewModel)
    private var isRefreshing = false
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
        viewModel.input.viewDidLoad.send(())
    }
    
    private func setupUI() {
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
        collectionView.backgroundColor = .gray0
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        // Input
        refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        // Output
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, sections: [StatisticsSection]) in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, route: StatisticsViewModel.Route) in
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
            case .bookmark:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StatisticsBookmarkCountCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StatisticsBookmarkCountCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
                
                return section
            case .feedback:
                let indexPath = IndexPath(item: 0, section: sectionIndex)
                guard case .feedback(let viewModel) = dataSource[indexPath] else { fatalError() }
                
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StatisticsFeedbackCountCell.Layout.calculateHeight(viewModel: viewModel))
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StatisticsFeedbackCountCell.Layout.calculateHeight(viewModel: viewModel))
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 10, leading: 24, bottom: 0, trailing: 24)
                
                return section
            case .review:
                guard let sectionIdentifier = dataSource.sectionIdentifier(section: sectionIndex) else { fatalError() }
                let item: NSCollectionLayoutItem
                let group: NSCollectionLayoutGroup
                let section: NSCollectionLayoutSection
                
                if sectionIdentifier.items.isEmpty {
                    item = NSCollectionLayoutItem(layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StatisticsReviewEmptyCell.Layout.height)
                    ))
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StatisticsReviewEmptyCell.Layout.height)
                    ), subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                } else {
                    item = NSCollectionLayoutItem(layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(StatisticsReviewCell.Layout.estimatedHeight)
                    ))
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(StatisticsReviewCell.Layout.estimatedHeight)
                    ), subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                }
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StatisticsReviewHeaderView.Layout.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )]
                
                if sectionIdentifier.items.isNotEmpty {
                    section.boundarySupplementaryItems.append(.init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(StatisticsReviewFooterView.Layout.height)
                        ),
                        elementKind: UICollectionView.elementKindSectionFooter,
                        alignment: .bottom
                    ))
                }
                
                section.contentInsets = .init(top: 20, leading: 0, bottom: 0, trailing: 0)
                
                return section
            }
        }
    }
}

// MARK: Route
extension StatisticsViewController {
    private func handleRoute(_ route: StatisticsViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .pushFeedbackDetail(let viewModel):
            pushFeedbackDetail(viewModel: viewModel)
        }
    }
    
    private func pushFeedbackDetail(viewModel: FeedbackDetailViewModel) {
        let viewController = FeedbackDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension StatisticsViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isRefreshing {
            viewModel.input.refresh.send(())
            isRefreshing = false
            refreshControl.endRefreshing()
        }
    }
}
