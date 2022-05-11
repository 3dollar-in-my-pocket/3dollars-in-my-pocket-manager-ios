import UIKit

final class StatisticsViewController: BaseViewController {
    private let statisticsView = StatisticsView()
    
    static func instance() -> StatisticsViewController {
        return StatisticsViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.statisticsView
    }
}
