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
            .drive(self.totalStatisticsView.tableView.rx.items(
                cellIdentifier: TotalStatisticsTableViewCell.registerId,
                cellType: TotalStatisticsTableViewCell.self
            )) { row, statistic, cell in
                cell.bind(statistics: statistic)
            }
            .disposed(by: self.disposeBag)
    }
}
