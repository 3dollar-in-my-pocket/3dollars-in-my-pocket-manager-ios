import UIKit
import CombineCocoa

final class CouponViewController: BaseViewController {
    override var screenName: ScreenName {
        viewModel.output.screenName
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let viewModel: CouponViewModel
    private lazy var dataSource = CouponDataSource(collectionView: collectionView)
    private var isRefreshing: Bool = false
    
    init(viewModel: CouponViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        collectionView.delegate = self
        viewModel.input.firstLoad.send(())
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.refreshControl = refreshControl
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: CouponViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        // Output
        viewModel.output.datasource
            .main
            .withUnretained(self)
            .sink { (owner: CouponViewController, sections: [CouponSection]) in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: CouponViewController, error: any Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: CouponViewController, route: CouponViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.isRefreshing
            .filter { $0.isNot }
            .main
            .withUnretained(self)
            .sink { (owner: CouponViewController, _) in
                owner.refreshControl.endRefreshing()
                owner.isRefreshing = false
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { (isShow: Bool) in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        return layout
    }
}

extension CouponViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = dataSource[indexPath] else { return .zero }
        
        let width = UIUtils.windowBounds.width
        switch section {
        case .empty:
            return CGSize(width: width, height: CouponEmptyCell.Layout.height)
        case .coupon(let viewModel):
            return CouponItemCell.Layout.size(width: width, viewModel: viewModel)
        }
    }
}

extension CouponViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard dataSource.sectionIdentifier(section: indexPath.section)?.type == .coupon else { return }
        
        viewModel.input.willDisplay.send(indexPath.item)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard isRefreshing else  { return }
        
        viewModel.input.refresh.send(())
    }
}

// MARK: Route
extension CouponViewController {
    private func handleRoute(_ route: CouponViewModel.Route) {
        switch route {
        case .showCloseAlert(let couponId):
            CouponCloseAlertViewController.present(from: self, couponId: couponId, onConfirm: { [weak self] couponId in
                self?.viewModel.input.closeCoupon.send(couponId)
            })
        }
    }
}
