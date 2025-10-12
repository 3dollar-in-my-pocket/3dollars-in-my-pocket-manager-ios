import Foundation
import Combine

extension CouponTabViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
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
    private var state = State()
    private let dependency: Dependency
    
    let activeCouponViewModel = CouponViewModel(statuses: [.active])
    let nonActiveCouponViewModel = CouponViewModel(statuses: [.ended])
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: CouponTabViewModel, _) in
                owner.output.setPageViewController.send((owner.activeCouponViewModel, owner.nonActiveCouponViewModel))
                
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
                owner.output.route.send(.pushCouponRegister(owner.bindCouponRegisterViewModel()))
            }
            .store(in: &cancellables)
    }
    
    private func bindCouponRegisterViewModel() -> CouponRegisterViewModel {
        let viewModel = CouponRegisterViewModel()
        viewModel.output.registerCompleted
            .subscribe(activeCouponViewModel.input.refresh)
            .store(in: &cancellables)
        return viewModel
    }
    
    private func bindActiveCouponViewModel() {
        activeCouponViewModel.output.closeCouponCompleted
            .subscribe(nonActiveCouponViewModel.input.refresh)
            .store(in: &activeCouponViewModel.cancellables)
    }
    
    private func bindNonActiveCouponViewModel() {
        
    }
}

// MARK: - Log
extension CouponTabViewModel {
    
}
