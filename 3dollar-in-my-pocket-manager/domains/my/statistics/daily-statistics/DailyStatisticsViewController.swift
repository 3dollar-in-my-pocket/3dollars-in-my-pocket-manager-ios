import UIKit

import ReactorKit

final class DailyStatisticsViewController: BaseViewController, View, DailyStatisticCoordinator {
    private let dailyStatisticsView = DailyStatisticsView()
    private let dailyStatisticsReactor = DailyStatisticsReactor(
        feedbackService: FeedbackService(),
        globalState: GlobalState.shared,
        userDefaults: Preference.shared
    )
    private weak var coordinator: DailyStatisticCoordinator?
    
    static func instance() -> DailyStatisticsViewController {
        return DailyStatisticsViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.dailyStatisticsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.dailyStatisticsReactor
        self.coordinator = self
        self.dailyStatisticsReactor.action.onNext(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dailyStatisticsReactor.action.onNext(.viewWillAppear)
    }
    
    override func bindEvent() {
        self.dailyStatisticsReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.dailyStatisticsReactor.updateTableViewHeightPublisher
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] statisticGroups in
                if let statisticsView = self?.parent?.parent?.view as? StatisticsView,
                   let dailyStatisticsViewHeight = self?.dailyStatisticsView
                    .calculatorTableViewHeight(statisticGroups: statisticGroups) {
//                    statisticsView.updateContainerViewHeight(
//                        tableViewHeight: dailyStatisticsViewHeight
//                    )
                }
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: DailyStatisticsReactor) {
        // Bind Action
        self.dailyStatisticsView.tableView.rx.willDisplayCell
            .map { Reactor.Action.willDisplayCell(index: $0.indexPath.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.statisticGroups }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] statisticGroups in
                if let statisticsView = self?.parent?.parent?.view as? StatisticsView,
                let dailyStatisticsViewHeight = self?.dailyStatisticsView
                    .calculatorTableViewHeight(statisticGroups: statisticGroups) {
//                    statisticsView.updateContainerViewHeight(
//                        tableViewHeight: dailyStatisticsViewHeight
//                    )
                }
            })
            .delay(.milliseconds(500))
                .drive(self.dailyStatisticsView.tableView.rx.items) { tableView, row, item in
                    if let statisticGroup = item {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyStatisticsTableViewCell.registerId) as? DailyStatisticsTableViewCell else { return UITableViewCell() }
                        
                        cell.bind(statisticGroup: statisticGroup)
                        return cell
                    } else {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyStatisticsEmptyTableViewCell.registerId) as? DailyStatisticsEmptyTableViewCell else { return UITableViewCell() }
                        
                        return cell
                    }
                }
            .disposed(by: self.disposeBag)
    }
    
    func refreshData() {
        self.dailyStatisticsReactor.action.onNext(.refresh)
    }
}
