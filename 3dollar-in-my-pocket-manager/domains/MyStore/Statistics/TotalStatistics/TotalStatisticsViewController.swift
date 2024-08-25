import UIKit

final class TotalStatisticsViewController: BaseViewController {
    enum Layout {
        static let spacing: CGFloat = 24
        static let topPadding: CGFloat = 32
    }
    
    private let viewModel: TotalStatisticsViewModel
    private let spaceView = UIView()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 24
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        stackView.layer.masksToBounds = true
        return stackView
    }()
    
    init(viewModel: TotalStatisticsViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppear.send(())
    }
    
    private func setupLayout() {
        stackView.addArrangedSubview(spaceView)
        stackView.setCustomSpacing(0, after: spaceView)
        spaceView.snp.makeConstraints {
            $0.height.equalTo(Layout.topPadding)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        // Output {
        viewModel.output.statistics
            .main
            .withUnretained(self)
            .sink { (owner: TotalStatisticsViewController, feedbacks: [FeedbackCountWithRatioResponse]) in
                for (index, feedback) in feedbacks.enumerated() {
                    guard let feedbackType = owner.getFeedbackType(feedback) else { continue }
                    let itemView = TotalStatisticsItemView()
                    itemView.bind(feedback: feedback, feedbackType: feedbackType, isTopRate: index < 3)
                    owner.stackView.addArrangedSubview(itemView)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: TotalStatisticsViewController, route: TotalStatisticsViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func getFeedbackType(_ feedback: FeedbackCountWithRatioResponse) -> FeedbackTypeResponse? {
        return viewModel.output.feedbackTypes.first { $0.feedbackType == feedback.feedbackType }
    }
    
//    override func bindEvent() {
//        self.totalStatisticsReactor.updateTableViewHeightPublisher
//            .asDriver(onErrorJustReturn: [])
//            .drive(onNext: { [weak self] statistics in
//                if let statisticsView = self?.parent?.parent?.view as? StatisticsView,
//                let totalStatisticsViewHeight = self?.totalStatisticsView
//                    .calculatorTableViewHeight(itemCount: statistics.count) {
//                    statisticsView.updateContainerViewHeight(
//                        tableViewHeight: totalStatisticsViewHeight
//                    )
//                }
//            })
//            .disposed(by: self.eventDisposeBag)
//    }
//    
//    func bind(reactor: TotalStatisticsReactor) {
//        // Bind State
//        reactor.state
//            .map { $0.statistics }
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: [])
//            .do(onNext: { [weak self] statistics in
//                if let statisticsView = self?.parent?.parent?.view as? StatisticsView,
//                let totalStatisticsViewHeight = self?.totalStatisticsView
//                    .calculatorTableViewHeight(itemCount: statistics.count) {
//                    statisticsView.updateContainerViewHeight(
//                        tableViewHeight: totalStatisticsViewHeight
//                    )
//                }
//            })
//            .delay(.milliseconds(500))
//            .drive(self.totalStatisticsView.tableView.rx.items(
//                cellIdentifier: TotalStatisticsTableViewCell.registerId,
//                cellType: TotalStatisticsTableViewCell.self
//            )) { row, statistic, cell in
//                cell.bind(statistics: statistic, isTopRate: row < 3)
//            }
//            .disposed(by: self.disposeBag)
//    }
//    
//    func refreshData() {
//        self.totalStatisticsReactor.action.onNext(.refresh)
//    }
}

// MARK: Route
extension TotalStatisticsViewController {
    private func handleRoute(_ route: TotalStatisticsViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
