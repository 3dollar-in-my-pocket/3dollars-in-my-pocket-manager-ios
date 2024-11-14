import Combine

extension MyPageViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapSubTab = PassthroughSubject<MyPageSubTabType, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .myStoreInfo
        let showNewBadge = PassthroughSubject<Void, Never>()
        let pageViewControllerIndex = CurrentValueSubject<Int, Never>(0)
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
    private var state: State
    private var dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.state = State()
        self.dependency = dependency
        super.init()
        bind()
    }
    
    private func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: MyPageViewModel, _) in
                owner.showMessageBadgeIfNeeded()
            }
            .store(in: &cancellables)
        
        input.didTapSubTab
            .withUnretained(self)
            .sink { (owner: MyPageViewModel, subTab: MyPageSubTabType) in
                guard let selectedIndex = owner.state.subTabs.firstIndex(of: subTab) else { return }
                owner.output.pageViewControllerIndex.send(selectedIndex)
                owner.sendClickSubTabLog(subTab)
            }
            .store(in: &cancellables)
    }
    
    private func showMessageBadgeIfNeeded() {
        guard dependency.preference.shownMessageNewBadge.isNot else { return }
        dependency.preference.shownMessageNewBadge = true
        output.showNewBadge.send(())
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
