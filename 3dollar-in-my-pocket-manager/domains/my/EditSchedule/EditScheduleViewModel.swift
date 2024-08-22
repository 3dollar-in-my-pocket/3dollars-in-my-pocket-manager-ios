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
