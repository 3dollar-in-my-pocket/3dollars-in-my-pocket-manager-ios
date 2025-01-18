import UIKit

import CombineCocoa

final class StatisticsViewController: BaseViewController {
    private let viewModel: StatisticsViewModel
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
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
        view.addSubview(collectionView)
        collectionView.backgroundColor = .gray0
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        // Input
//        statisticsView.refreshControl.isRefreshingPublisher
//            .filter { $0 }
//            .withUnretained(self)
//            .sink { (owner: StatisticsViewController, _) in
//                owner.isRefreshing = true
//            }
//            .store(in: &cancellables)
        
        // Output
        viewModel.output.subscriberCount
            .main
            .withUnretained(self)
            .sink { (owner: StatisticsViewController, subscriberCount: Int) in
//                owner.statisticsView.favoriteCountLabel.bind(subscriberCount)
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
                fatalError("정의되지 않은 섹션입니다.")
            case .review:
                fatalError("정의되지 않은 섹션입니다.")
            }
        }
    }
}

//extension StatisticsViewController: UIScrollViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if isRefreshing {
//            viewModel.input.refresh.send(())
//            isRefreshing = false
//            statisticsView.refreshControl.endRefreshing()
//        }
//    }
//}
