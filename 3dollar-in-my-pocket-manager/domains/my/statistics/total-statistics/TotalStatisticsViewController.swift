import UIKit

final class TotalStatisticsViewController: BaseViewController {
    private let totalStatisticsView = TotalStatisticsView()
    
    static func instance() -> TotalStatisticsViewController {
        return TotalStatisticsViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.totalStatisticsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.totalStatisticsView.tableView.dataSource = self
        self.totalStatisticsView.tableView.delegate = self
    }
}

extension TotalStatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TotalStatisticsTableViewCell.registerId,
            for: indexPath
        ) as? TotalStatisticsTableViewCell else { return BaseTableViewCell() }
        
        return cell
    }
}
