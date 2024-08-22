import Foundation
import Combine

extension EditScheduleViewModel {
    struct Input {
        let didTapDayOfTheWeek = PassthroughSubject<DayOfTheWeek, Never>()
        let inputStartTime = PassthroughSubject<(day: DayOfTheWeek, time: String), Never>()
        let inputEndTime = PassthroughSubject<(day: DayOfTheWeek, time: String), Never>()
        let inputLocation = PassthroughSubject<(day: DayOfTheWeek, location: String), Never>()
        let didTapSaveButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .editSchedule
        let store: CurrentValueSubject<BossStoreResponse, Never>
        let updatedStore = PassthroughSubject<BossStoreResponse, Never>()
        let toast = PassthroughSubject<String, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var store: BossStoreResponse
    }
    
    struct Config {
        let store: BossStoreResponse
    }
    
    enum Route {
        case showErrorAlert(Error)
        case pop
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let logManager: LogManager
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManager = LogManager.shared
        ) {
            self.storeRepository = storeRepository
            self.logManager = logManager
        }
    }
}

final class EditScheduleViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(store: .init(config.store))
        self.state = State(store: config.store)
        self.dependency = dependency
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapDayOfTheWeek
            .withUnretained(self)
            .sink { (owner: EditScheduleViewModel, dayOfTheWeek: DayOfTheWeek) in
                owner.handleTapDayOfTheWeek(dayOfTheWeek)
            }
            .store(in: &cancellables)
        
        input.inputStartTime
            .withUnretained(self)
            .sink { (owner: EditScheduleViewModel, value: (day: DayOfTheWeek, time: String)) in
                guard let targetIndex = owner.getIndexOf(value.day) else { return }
                owner.state.store.appearanceDays[targetIndex].openingHours.startTime = value.time
            }
            .store(in: &cancellables)
        
        input.inputEndTime
            .withUnretained(self)
            .sink { (owner: EditScheduleViewModel, value: (day: DayOfTheWeek, time: String)) in
                guard let targetIndex = owner.getIndexOf(value.day) else { return }
                owner.state.store.appearanceDays[targetIndex].openingHours.endTime = value.time
            }
            .store(in: &cancellables)
        
        input.inputLocation
            .withUnretained(self)
            .sink { (owner: EditScheduleViewModel, value: (day: DayOfTheWeek, location: String)) in
                guard let targetIndex = owner.getIndexOf(value.day) else { return }
                owner.state.store.appearanceDays[targetIndex].locationDescription = value.location
            }
            .store(in: &cancellables)
        
        input.didTapSaveButton
            .withUnretained(self)
            .sink { (owner: EditScheduleViewModel, _) in
                owner.updateStore()
            }
            .store(in: &cancellables)
    }
    
    private func handleTapDayOfTheWeek(_ dayOfTheWeek: DayOfTheWeek) {
        if let targetIndex = state.store.appearanceDays.firstIndex(where: { $0.dayOfTheWeek == dayOfTheWeek }) {
            state.store.appearanceDays.remove(at: targetIndex)
        } else {
            let appearanceDay = BossStoreAppearanceDayResponse(dayOfTheWeek: dayOfTheWeek)
            state.store.appearanceDays.append(appearanceDay)
        }
        output.store.send(state.store)
    }
    
    private func getIndexOf(_ day: DayOfTheWeek) -> Int? {
        return state.store.appearanceDays.firstIndex { $0.dayOfTheWeek == day }
    }
    
    private func updateStore() {
        output.showLoading.send(true)
        Task { [weak self] in
            guard let self else { return }
            
            let request = state.store.toPatchRequest()
            let result = await dependency.storeRepository.editStore(storeId: state.store.bossStoreId, request: request)
            
            switch result {
            case .success(_):
                output.showLoading.send(false)
                sendEditScheduleLog()
                output.updatedStore.send(state.store)
                output.toast.send("정보가 업데이트 되었습니다")
                output.route.send(.pop)
            case .failure(let error):
                output.showLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}

// MARK: Log
extension EditScheduleViewModel {
    func sendEditScheduleLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .editSchedule,
            extraParameters: [.storeId: state.store.bossStoreId]
        ))
    }
}

//
//final class EditScheduleReactor:  BaseReactor, Reactor {
//    enum Action {
//        case tapDayOfTheWeek(DayOfTheWeek)
//        case inputStartTime(day: DayOfTheWeek, time: String)
//        case inputEndTime(day: DayOfTheWeek, time: String)
//        case inputLocation(day: DayOfTheWeek, location: String)
//        case tapEditButton
//    }
//    
//    enum Mutation {
//        case addDayOfWeek(DayOfTheWeek)
//        case removeDayOfWeek(DayOfTheWeek)
//        case setStartTime(day: DayOfTheWeek, time: String)
//        case setEndTime(day: DayOfTheWeek, time: String)
//        case setLocation(day: DayOfTheWeek, location: String)
//        case pop
//        case showLoading(isShow: Bool)
//        case showErrorAlert(Error)
//    }
//    
//    struct State {
//        var store: Store
//    }
//    
//    let initialState: State
//    let popPublisher = PublishRelay<Void>()
//    private let storeService: StoreServiceType
//    private let globalState: GlobalState
//    private let logManager: LogManager
//    
//    init(
//        store: Store,
//        storeService: StoreServiceType,
//        globalState: GlobalState,
//        logManager: LogManager
//    ) {
//        self.initialState = State(store: store)
//        self.storeService = storeService
//        self.globalState = globalState
//        self.logManager = logManager
//    }
//    
//    func mutate(action: Action) -> Observable<Mutation> {
//        switch action {
//        case .tapDayOfTheWeek(let dayOfWeek):
//            let isContainsDayOfWeek = self.currentState.store.appearanceDays.contains {
//                $0.dayOfTheWeek == dayOfWeek
//            }
//        
//            if isContainsDayOfWeek {
//                return .just(.removeDayOfWeek(dayOfWeek))
//            } else {
//                return .just(.addDayOfWeek(dayOfWeek))
//            }
//            
//        case .inputStartTime(let day, let time):
//            return .just(.setStartTime(day: day, time: time))
//            
//        case .inputEndTime(let day, let time):
//            return .just(.setEndTime(day: day, time: time))
//            
//        case .inputLocation(let day, let location):
//            return .just(.setLocation(day: day, location: location))
//            
//        case .tapEditButton:
//            return .concat([
//                .just(.showLoading(isShow: true)),
//                self.updateStore(store: self.currentState.store),
//                .just(.showLoading(isShow: false))
//            ])
//        }
//    }
//    
//    func reduce(state: State, mutation: Mutation) -> State {
//        var newState = state
//        
//        switch mutation {
//        case .addDayOfWeek(let dayOfTheWeek):
//            let appearanceDay = AppearanceDay(dayOfTheWeek: dayOfTheWeek)
//            
//            newState.store.appearanceDays.append(appearanceDay)
//            newState.store.appearanceDays.sort()
//            
//        case .removeDayOfWeek(let dayOfTheWeek):
//            let firstIndex = state.store.appearanceDays.firstIndex {
//                $0.dayOfTheWeek == dayOfTheWeek
//            }
//            
//            if let firstIndex = firstIndex {
//                newState.store.appearanceDays.remove(at: firstIndex)
//            }
//            newState.store.appearanceDays.sort()
//            
//        case .setStartTime(let dayOfTheWeek, let time):
//            if let index = self.getIndex(of: dayOfTheWeek) {
//                newState.store.appearanceDays[index].openingHours.startTime = time
//            }
//            
//        case .setEndTime(let dayOfTheWeek, let time):
//            if let index = self.getIndex(of: dayOfTheWeek) {
//                newState.store.appearanceDays[index].openingHours.endTime = time
//            }
//            
//        case .setLocation(let dayOfTheWeek, let location):
//            if let index = self.getIndex(of: dayOfTheWeek) {
//                newState.store.appearanceDays[index].locationDescription = location
//            }
//            
//        case .pop:
//            self.popPublisher.accept(())
//            
//        case .showLoading(let isShow):
//            self.showLoadginPublisher.accept(isShow)
//            
//        case .showErrorAlert(let error):
//            self.showErrorAlert.accept(error)
//        }
//        
//        return newState
//    }
//    
//    private func getIndex(of dayOfTheWeek: DayOfTheWeek) -> Int? {
//        return self.currentState.store.appearanceDays.firstIndex {
//            $0.dayOfTheWeek == dayOfTheWeek
//        }
//    }
//    
//    private func updateStore(store: Store) -> Observable<Mutation> {
//        return self.storeService.updateStore(store: store)
//            .do(onNext: { [weak self] _ in
//                guard let self = self else { return }
//                
//                self.globalState.updateStorePublisher.onNext(store)
//                logManager.sendEvent(.init(
//                    screen: .editSchedule,
//                    eventName: .editSchedule,
//                    extraParameters: [.storeId: currentState.store.id]
//                ))
//            })
//            .map { _ in Mutation.pop }
//            .catch {
//                return .merge([
//                    .just(.showLoading(isShow: false)),
//                    .just(.showErrorAlert($0))
//                ])
//            }
//    }
//}
