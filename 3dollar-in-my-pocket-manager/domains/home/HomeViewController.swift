import UIKit

import ReactorKit

final class HomeViewController: BaseViewController, View {
    private let homeView = HomeView()
    private let homeReactor = HomeReactor()
    
    static func instance() -> HomeViewController {
        return HomeViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.homeView
        
        self.reactor = self.homeReactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bind(reactor: HomeReactor) {
        // Bind action
        self.homeView.salesToggleView.rx.tapButton
            .map { Reactor.Action.tapSalesToggle }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind state
        reactor.state
            .map { $0.isOnSales }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.homeView.salesToggleView.rx.isOn)
            .disposed(by: self.disposeBag)
    }
}
