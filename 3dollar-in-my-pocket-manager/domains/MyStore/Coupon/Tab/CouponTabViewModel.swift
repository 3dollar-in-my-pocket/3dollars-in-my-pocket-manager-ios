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
        let route = PassthroughSubject<Route, Never>()
        let isEnabledRegisterButton = CurrentValueSubject<Bool, Never>(true)
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
        let preference: Preference
        
        init(
            couponRepository: CouponRepository = CouponRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = Preference.shared
        ) {
            self.couponRepository = couponRepository
            self.logManager = logManager
            self.preference = preference
        }
    }
}

final class CouponTabViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    
    let activeCouponViewModel = CouponViewModel(statuses: [.stopped])
    let nonActiveCouponViewModel = CouponViewModel(statuses: [.ended])
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
        bindActiveCouponViewModel()
        bindNonActiveCouponViewModel()
    }
    
    private func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: CouponTabViewModel, _) in
                owner.output.setPageViewController.send((owner.activeCouponViewModel, owner.nonActiveCouponViewModel))
                
            }
            .store(in: &cancellables)
        
        input.viewDidLoad
            .merge(with: input.refresh)
            .withUnretained(self)
            .sink { (owner: CouponTabViewModel, _) in
                owner.loadActiveCoupon()
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
            .sink { [weak self] in
                self?.activeCouponViewModel.input.refresh.send()
                self?.input.refresh.send()
            }
            .store(in: &cancellables)
        return viewModel
    }
    
    private func loadActiveCoupon() {
        Task {
            let couponResult = await dependency.couponRepository.fetchCoupons(storeId: dependency.preference.storeId, statuses: [.active], cursor: nil)
            
            switch couponResult {
            case .success(let response):
                activeCouponViewModel.input.pinnedCoupon.send(response.contents.first)
                output.isEnabledRegisterButton.send(response.contents.first.isNil)
            case .failure(let error):
                break //
            }
        }
    }
    
    private func bindActiveCouponViewModel() {
        activeCouponViewModel.output.closeCouponCompleted
            .sink { [weak self] in
                self?.nonActiveCouponViewModel.input.refresh.send()
                self?.input.refresh.send()
            }
            .store(in: &activeCouponViewModel.cancellables)
    }
    
    private func bindNonActiveCouponViewModel() {
        
    }
}

// MARK: - Log
extension CouponTabViewModel {
    
}
