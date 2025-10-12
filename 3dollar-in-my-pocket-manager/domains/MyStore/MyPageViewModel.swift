import Combine

extension MyPageViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let willAppear = PassthroughSubject<Void, Never>()
        let didTapSubTab = PassthroughSubject<MyPageSubTabType, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .myStoreInfo
        let showNewBadge = PassthroughSubject<Void, Never>()
        let showMessageTooptip = PassthroughSubject<Bool, Never>()
        let showCouponTooltip = PassthroughSubject<Bool, Never>()
        let pageViewControllerIndex = CurrentValueSubject<Int, Never>(0)
        let selectSubTab = PassthroughSubject<MyPageSubTabType, Never>()
    }
    
    struct State {
        var subTabs: [MyPageSubTabType] = MyPageSubTabType.allCases
    }
    
    struct Dependency {
        let logManager: LogManagerProtocol
        var preference: Preference
        
        init(logManager: LogManagerProtocol = LogManager.shared, preference: Preference = .shared) {
            self.logManager = logManager
            self.preference = preference
        }
    }
}

final class MyPageViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    let statisticsViewModel = StatisticsViewModel()
    private var state: State
    private var dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.state = State()
        self.dependency = dependency
        super.init()
        bind()
        bindStatisticsViewModel()
    }
    
    private func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: MyPageViewModel, _) in
                owner.showCouponBadgeIfNeeded()
            }
            .store(in: &cancellables)
        
        input.willAppear
            .withUnretained(self)
            .sink { (owner: MyPageViewModel, _) in
                owner.showCouponTooltipIfNeeded()
            }
            .store(in: &cancellables)
        
        input.didTapSubTab
            .withUnretained(self)
            .sink { (owner: MyPageViewModel, subTab: MyPageSubTabType) in
                guard let selectedIndex = owner.state.subTabs.firstIndex(of: subTab) else { return }
                owner.output.pageViewControllerIndex.send(selectedIndex)
                owner.output.selectSubTab.send(subTab)
                owner.sendClickSubTabLog(subTab)
                
                if subTab == .coupon {
                    owner.dependency.preference.shownMyPageCouponTooltip = true
                    owner.output.showCouponTooltip.send(false)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindStatisticsViewModel() {
        statisticsViewModel.output.didTapMessage
            .map { MyPageSubTabType.message }
            .subscribe(input.didTapSubTab)
            .store(in: &statisticsViewModel.cancellables)
    }
    
    private func showCouponBadgeIfNeeded() {
        guard dependency.preference.shownCouponNewBadge.isNot else { return }
        dependency.preference.shownCouponNewBadge = true
        output.showNewBadge.send(())
    }
    
    private func showCouponTooltipIfNeeded() {
        let shownCouponTooltip = dependency.preference.shownMyPageCouponTooltip
        output.showCouponTooltip.send(!shownCouponTooltip)
    }
}

// MARK: Log
extension MyPageViewModel {
    private func sendClickSubTabLog(_ subTab: MyPageSubTabType) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .tapMyTopTab,
            extraParameters: [.tab: subTab.tabName]
        ))
    }
}
