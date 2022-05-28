import UIKit

final class DailyStatisticsViewController: BaseViewController {
    private let dailyStatisticsView = DailyStatisticsView()
    
    static func instance() -> DailyStatisticsViewController {
        return DailyStatisticsViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.dailyStatisticsView
    }
}
