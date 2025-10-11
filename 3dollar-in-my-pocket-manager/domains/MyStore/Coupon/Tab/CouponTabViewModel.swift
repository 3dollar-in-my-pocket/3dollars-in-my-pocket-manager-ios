import Foundation
import Combine

extension CouponTabViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let didTapTabButton = PassthroughSubject<CouponTabButton.CouponTabType, Never>()
        let didTapRegisterButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .couponTab
        let setPageViewController = PassthroughSubject<(CouponViewModel, CouponViewModel), Never>()
        let tab = CurrentValueSubject<CouponTabButton.CouponTabType, Never>(.active)
        let updateContainerHeight = PassthroughSubject<CGFloat, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Relay {
        let didTapTabButton = PassthroughSubject<CouponTabButton.CouponTabType, Never>()
        let updateContainerHeight = PassthroughSubject<CGFloat, Never>()
    }
    
    enum Route {
        case showErrorAlert(Error)
        case pushCouponRegister(CouponRegisterViewModel)
    }
    
    struct State {
        var selectedTab: CouponTabButton.CouponTabType = .active
    }
    
    struct Dependency {
        let couponRepository: CouponRepository
        let logManager: LogManagerProtocol
        
        init(
            couponRepository: CouponRepository = CouponRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.couponRepository = couponRepository
            self.logManager = logManager
        }
    }
}

final class CouponTabViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let relay = Relay()
    private var state = State()
    private let dependency: Dependency
    
    var activeCouponViewModel: CouponViewModel?
    var nonActiveCouponViewModel: CouponViewModel?
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
        bindRelay()
    }
    
    private func bind() {
        Publishers.Merge(input.viewDidLoad, input.refresh)
            .withUnretained(self)
            .sink { (owner: CouponTabViewModel, _) in
                owner.fetchDatas()
            }
            .store(in: &cancellables)
        
        input.didTapTabButton
            .withUnretained(self)
            .sink { (owner: CouponTabViewModel, tab: CouponTabButton.CouponTabType) in
                owner.state.selectedTab = tab
                owner.output.tab.send(tab)
            }
            .store(in: &cancellables)
        
        input.didTapRegisterButton
            .withUnretained(self)
            .sink { (owner: CouponTabViewModel, _) in
                owner.output.route.send(.pushCouponRegister(CouponRegisterViewModel()))
            }
            .store(in: &cancellables)
    }
    
    private func bindRelay() {        
        relay.updateContainerHeight
            .subscribe(output.updateContainerHeight)
            .store(in: &cancellables)
    }
    
    private func fetchDatas() {
        let activeCouponViewModel = bindCouponViewModel(statuses: [.active])
        self.activeCouponViewModel = activeCouponViewModel
        
        let nonActiveCouponViewModel = bindCouponViewModel(statuses: [.ended])
        self.nonActiveCouponViewModel = nonActiveCouponViewModel
        
        output.setPageViewController.send((activeCouponViewModel, nonActiveCouponViewModel))
        
    }
    
    private func bindCouponViewModel(statuses: [StoreCouponStatus]) -> CouponViewModel {
        let viewModel = CouponViewModel(statuses: statuses)
        
        return viewModel
    }
}

// MARK: - Log
extension CouponTabViewModel {
    
}
