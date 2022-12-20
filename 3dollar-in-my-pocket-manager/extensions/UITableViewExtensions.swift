import UIKit

extension UITableView {
    func register(_ types: [BaseTableViewCell.Type]) {
        for type in types {
            self.register(type, forCellReuseIdentifier: "\(type.self)")
        }
    }
    
    func addIndicatorFooter() {
        let indicator = UIActivityIndicatorView(style: .medium)
        
        indicator.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 60
        )
        self.tableFooterView = indicator
    }
}
