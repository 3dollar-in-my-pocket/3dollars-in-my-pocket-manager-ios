import UIKit

final class ReviewListViewController: BaseViewController {
    private let refreshControl = UIRefreshControl()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.backgroundColor = .gray0
        return collectionView
    }()
    
    private let viewModel: ReviewListViewModel
    private lazy var dataSource = ReviewListDataSource(
        collectionView: collectionView,
        viewModel: viewModel
    )
    private var isRefreshing = false
    
    init(viewModel: ReviewListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
        overrideUserInterfaceStyle = .light
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationBar()
        setupUI()
        bind()
        viewModel.input.firstLoad.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = Strings.ReviewList.title
        collectionView.dataSource = dataSource
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: ReviewListViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        // Output
        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { (owner: ReviewListViewController, sections: [ReviewListSection]) in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: ReviewListViewController, route: ReviewListViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
}

extension ReviewListViewController {
    private func handleRoute(_ route: ReviewListViewModel.Route) {
        switch route {
        case .presentPhotoDetail(let viewModel):
            presentPhotoDetail(viewModel: viewModel)
        case .pushReviewDetail(let viewModel):
            pushReviewDetail(viewModel: viewModel)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
    
    private func presentPhotoDetail(viewModel: PhotoDetailViewModel) {
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        present(viewController, animated: true, completion: nil)
    }
    
    private func pushReviewDetail(viewModel: ReviewDetailViewModel) {
        let viewController = ReviewDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ReviewListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return .zero }
        
        switch item {
        case .overview:
            return CGSize(width: UIUtils.windowBounds.width, height: ReviewOverviewCell.Layout.height)
        case .review(let viewModel):
            if viewModel.output.review.status == .filtered {
                return CGSize(width: UIUtils.windowBounds.width, height: 86)
            } else {
                return CGSize(
                    width: UIUtils.windowBounds.width,
                    height: ReviewListItemCell.Layout.calculateHeight(review: viewModel.output.review)
                )
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize(width: UIUtils.windowBounds.width, height: ReviewListHeaderView.Layout.height)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard let sectionIdentifier = dataSource.sectionIdentifier(section: section) else { return .zero }
        switch sectionIdentifier.type {
        case .overview:
            return .zero
        case .reviewList:
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let sectionIdentifier = dataSource.sectionIdentifier(section: section) else { return .zero }
        switch sectionIdentifier.type {
        case .overview:
            return .zero
        case .reviewList:
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        viewModel.input.cellWillDisplay.send(indexPath.item)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isRefreshing {
            viewModel.input.refresh.send(())
            isRefreshing = false
            refreshControl.endRefreshing()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapReview.send(indexPath.item)
    }
}
