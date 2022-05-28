import UIKit

import RxSwift
import RxCocoa
import ReactorKit

final class TotalStatisticsViewController: BaseViewController, View, TotalStatisticsCoordinator {
    private let totalStatisticsView = TotalStatisticsView()
    private let totalStatisticsReactor = TotalStatisticsReactor(
        feedbackService: FeedbackService(),
        userDefaults: UserDefaultsUtils()
    )
    private weak var coordinator: TotalStatisticsCoordinator?
    
    static func instance() -> TotalStatisticsViewController {
        return TotalStatisticsViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.totalStatisticsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.totalStatisticsReactor
        self.totalStatisticsReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.totalStatisticsReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: TotalStatisticsReactor) {
        // Bind State
        reactor.state
            .map { $0.statistics }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] statistics in
                if let statisticsView = self?.parent?.parent?.view as? StatisticsView,
                let totalStatisticsViewHeight = self?.totalStatisticsView
                    .calculatorTableViewHeight(itemCount: statistics.count) {
                    statisticsView.updateContainerViewHeight(
                        tableViewHeight: totalStatisticsViewHeight
                    )
                }
            })
            .drive(self.totalStatisticsView.tableView.rx.items(
                cellIdentifier: TotalStatisticsTableViewCell.registerId,
                cellType: TotalStatisticsTableViewCell.self
            )) { row, statistic, cell in
                cell.bind(statistics: statistic, isTopRate: row < 3)
            }
            .disposed(by: self.disposeBag)
    }
}
