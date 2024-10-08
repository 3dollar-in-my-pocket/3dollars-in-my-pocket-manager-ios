import Combine

import ReactorKit
import RxSwift
import RxCocoa

extension MyStoreInfoViewModel {
    enum Constants {
        static let maxShowingMenuCount = 4
    }
    
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let didTapHeaderRightButton = PassthroughSubject<MyStoreInfoSection.SectionType, Never>()
        let didUpdatedAccountInfo = PassthroughSubject<BossStoreAccountNumber, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .myStoreInfo
        let dataSource = PassthroughSubject<[MyStoreInfoSection], Never>()
        let isRefreshing = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var store: BossStoreResponse?
    }
    
    enum Route {
        case pushEditAccount(EditAccountViewModel)
        case pushEditStoreInfo(EditStoreInfoViewModel)
        case pushEditIntroduction(EditIntroductionViewModel)
        case pushEditMenus(EditMenuViewModel)
        case pushEditAppearanceDays(EditScheduleViewModel)
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.storeRepository = storeRepository
            self.logManager = logManager
        }
    }
}

final class MyStoreInfoViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewModel, _) in
                owner.fetchMyStore()
            }
            .store(in: &cancellables)
        
        input.refresh
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewModel, _) in
                owner.output.isRefreshing.send(true)
                owner.fetchMyStore()
            }
            .store(in: &cancellables)
        
        input.didTapHeaderRightButton
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewModel, sectionType: MyStoreInfoSection.SectionType) in
                owner.sendClickRightButtonLog(sectionType: sectionType)
                owner.handleSectionHeaderButton(sectionType: sectionType)
            }
            .store(in: &cancellables)
    }
    
    private func fetchMyStore() {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.storeRepository.fetchMyStore()
            
            switch result {
            case .success(let store):
                state.store = store
                updateDataSource()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
            
            output.isRefreshing.send(false)
        }
    }
    
    private func updateDataSource() {
        guard let store = state.store else { return }
        var sections: [MyStoreInfoSection] = [
            MyStoreInfoSection(type: .overview, items: [.overView(store)]),
            MyStoreInfoSection(type: .introduction, items: [.introduction(store.introduction)])
        ]
        
        if store.menus.isEmpty {
            sections.append(MyStoreInfoSection(type: .menu, items: [.emptyMenu]))
        } else if store.menus.count < Constants.maxShowingMenuCount {
            sections.append(MyStoreInfoSection(type: .menu, items: store.menus.map { .menu($0) }))
        } else {
            let menuItems = store.menus[..<(Constants.maxShowingMenuCount-1)].map { MyStoreInfoSectionItem.menu($0) }
            let moreItem = MyStoreInfoSectionItem.menuMore(Array(store.menus[(Constants.maxShowingMenuCount-1)...]))

            sections.append(MyStoreInfoSection(type: .menu, items: menuItems + [moreItem]))
        }
        
        sections.append(MyStoreInfoSection(type: .account, items: [.account(store.accountNumbers)]))
        sections.append(createAppearanceSection(from: store.appearanceDays))
        output.dataSource.send(sections)
    }
    
    private func createAppearanceSection(from appearanceDays: [BossStoreAppearanceDayResponse]) -> MyStoreInfoSection {
        var initialAppearanceDays: [BossStoreAppearanceDayResponse] = [
            .init(dayOfTheWeek: .monday),
            .init(dayOfTheWeek: .tuesday),
            .init(dayOfTheWeek: .wednesday),
            .init(dayOfTheWeek: .thursday),
            .init(dayOfTheWeek: .friday),
            .init(dayOfTheWeek: .saturday),
            .init(dayOfTheWeek: .sunday),
        ]
        
        for appearanceDay in appearanceDays {
            initialAppearanceDays[appearanceDay.dayOfTheWeek.index] = appearanceDay
            initialAppearanceDays[appearanceDay.dayOfTheWeek.index].isClosedDay = false
        }
        
        let items = initialAppearanceDays.map { MyStoreInfoSectionItem.appearanceDay($0) }
        
        return .init(type: .appearanceDay, items: items)
    }
    
    private func handleSectionHeaderButton(sectionType: MyStoreInfoSection.SectionType) {
        guard let store = state.store else { return }
        switch sectionType {
        case .overview:
            pushEditStoreInfo()
        case .introduction:
            pushEditIntroduction()
        case .menu:
            pushEditMenus()
        case .account:
            pushEditAccount()
        case .appearanceDay:
            pushEditSchedule()
        }
    }
    
    private func bindEditStoreInfoViewModel(_ viewModel: EditStoreInfoViewModel) {
        viewModel.output.updatedStore
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewModel, store: BossStoreResponse) in
                owner.state.store = store
                owner.updateDataSource()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func bindEditIntroductionViewModel(_ viewModel: EditIntroductionViewModel) {
        viewModel.output.updatedStore
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewModel, store: BossStoreResponse) in
                owner.state.store = store
                owner.updateDataSource()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func bindEditMenuViewModel(_ viewModel: EditMenuViewModel) {
        viewModel.output.updatedStore
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewModel, store: BossStoreResponse) in
                owner.state.store = store
                owner.updateDataSource()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func bindEditAccountViewModel(_ viewModel: EditAccountViewModel) {
        viewModel.output.updatedStore
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewModel, store: BossStoreResponse) in
                owner.state.store = store
                owner.updateDataSource()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func bindEditScheduleViewModel(_ viewModel: EditScheduleViewModel) {
        viewModel.output.updatedStore
            .withUnretained(self)
            .sink { (owner: MyStoreInfoViewModel, store: BossStoreResponse) in
                owner.state.store = store
                owner.updateDataSource()
            }
            .store(in: &viewModel.cancellables)
    }
}

// MARK: Rotue
extension MyStoreInfoViewModel {
    private func pushEditStoreInfo() {
        guard let store = state.store else { return }
        let config = EditStoreInfoViewModel.Config(store: store)
        let viewModel = EditStoreInfoViewModel(config: config)
        
        bindEditStoreInfoViewModel(viewModel)
        output.route.send(.pushEditStoreInfo(viewModel))
    }
    
    private func pushEditIntroduction() {
        guard let store = state.store else { return }
        let config = EditIntroductionViewModel.Config(store: store)
        let viewModel = EditIntroductionViewModel(config: config)
        
        bindEditIntroductionViewModel(viewModel)
        output.route.send(.pushEditIntroduction(viewModel))
    }
    
    private func pushEditMenus() {
        guard let store = state.store else { return }
        let config = EditMenuViewModel.Config(store: store)
        let viewModel = EditMenuViewModel(config: config)
        
        bindEditMenuViewModel(viewModel)
        output.route.send(.pushEditMenus(viewModel))
    }
    
    private func pushEditAccount() {
        guard let store = state.store else { return }
        let config = EditAccountViewModel.Config(store: store)
        let viewModel = EditAccountViewModel(config: config)
        
        bindEditAccountViewModel(viewModel)
        output.route.send(.pushEditAccount(viewModel))
    }
    
    private func pushEditSchedule() {
        guard let store = state.store else { return }
        let config = EditScheduleViewModel.Config(store: store)
        let viewModel = EditScheduleViewModel(config: config)
        
        bindEditScheduleViewModel(viewModel)
        output.route.send(.pushEditAppearanceDays(viewModel))
    }
}

// MARK: Log
extension MyStoreInfoViewModel {
    func sendClickRightButtonLog(sectionType: MyStoreInfoSection.SectionType) {
        guard let storeId = state.store?.bossStoreId else { return }
        var eventName: EventName? {
            switch sectionType {
            case .overview:
                return nil
            case .introduction:
                return .tapEditIntroduction
            case .menu:
                return .tapEditMenu
            case .account:
                return nil
            case .appearanceDay:
                return .tapEditSchedule
            }
        }
        
        guard let eventName else { return }
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: eventName,
            extraParameters: [.storeId: storeId])
        )
    }
}
