import UIKit

final class DailyStatisticsViewController: BaseViewController {
    private lazy var collectionView: UICollectionView = {
       let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let viewModel: DailyStatisticsViewModel
    private var datasource: [FeedbackGroupingDateResponse] = []
    
    init(viewModel: DailyStatisticsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind()
        viewModel.input.viewDidLoad.send(())
    }
    
    private func setupLayout() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register([
            BaseCollectionViewCell.self,
            DailyStatisticsCell.self,
            DailyStatisticsEmptyCell.self
        ])
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        // Output
        viewModel.output.statisticGroups
            .main
            .withUnretained(self)
            .sink { (owner: DailyStatisticsViewController, groups:  [FeedbackGroupingDateResponse]) in
                owner.datasource = groups
                owner.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: DailyStatisticsViewController, route: DailyStatisticsViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        return layout
    }
}

extension DailyStatisticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.isEmpty ? 1 : datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if datasource.isEmpty {
            let cell: DailyStatisticsEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        } else {
            guard let feedbackGroup = datasource[safe: indexPath.item] else { return BaseCollectionViewCell() }
            let cell: DailyStatisticsCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(feedbackGroup: feedbackGroup, feedbackTypes: viewModel.output.feedbackTypes)
            return cell
        }
    }
}

extension DailyStatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let feedbackGroup = datasource[safe: indexPath.item] else {
            return DailyStatisticsEmptyCell.Layout.size
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
}

// MARK: Route
extension DailyStatisticsViewController {
    func handleRoute(_ route: DailyStatisticsViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
