import Foundation

import ReactorKit
import RxSwift
import RxCocoa

final class EditScheduleReactor:  BaseReactor, Reactor {
    enum Action {
        case tapDayOfTheWeek(DayOfTheWeek)
        case inputStartTime(day: DayOfTheWeek, time: String)
        case inputEndTime(day: DayOfTheWeek, time: String)
        case inputLocation(day: DayOfTheWeek, location: String)
        case tapEditButton
    }
    
    enum Mutation {
        case addDayOfWeek(DayOfTheWeek)
        case removeDayOfWeek(DayOfTheWeek)
        case setStartTime(day: DayOfTheWeek, time: String)
        case setEndTime(day: DayOfTheWeek, time: String)
        case setLocation(day: DayOfTheWeek, location: String)
        case pop
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var store: Store
    }
    
    let initialState: State
    let popPublisher = PublishRelay<Void>()
    private let storeService: StoreServiceType
    private let globalState: GlobalState
    private let logManager: LogManager
    
    init(
        store: Store,
        storeService: StoreServiceType,
        globalState: GlobalState,
        logManager: LogManager
    ) {
        self.initialState = State(store: store)
        self.storeService = storeService
        self.globalState = globalState
        self.logManager = logManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapDayOfTheWeek(let dayOfWeek):
            let isContainsDayOfWeek = self.currentState.store.appearanceDays.contains {
                $0.dayOfTheWeek == dayOfWeek
            }
        
            if isContainsDayOfWeek {
                return .just(.removeDayOfWeek(dayOfWeek))
            } else {
                return .just(.addDayOfWeek(dayOfWeek))
            }
            
        case .inputStartTime(let day, let time):
            return .just(.setStartTime(day: day, time: time))
            
        case .inputEndTime(let day, let time):
            return .just(.setEndTime(day: day, time: time))
            
        case .inputLocation(let day, let location):
            return .just(.setLocation(day: day, location: location))
            
        case .tapEditButton:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.updateStore(store: self.currentState.store),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .addDayOfWeek(let dayOfTheWeek):
            let appearanceDay = AppearanceDay(dayOfTheWeek: dayOfTheWeek)
            
            newState.store.appearanceDays.append(appearanceDay)
            newState.store.appearanceDays.sort()
            
        case .removeDayOfWeek(let dayOfTheWeek):
            let firstIndex = state.store.appearanceDays.firstIndex {
                $0.dayOfTheWeek == dayOfTheWeek
            }
            
            if let firstIndex = firstIndex {
                newState.store.appearanceDays.remove(at: firstIndex)
            }
            newState.store.appearanceDays.sort()
            
        case .setStartTime(let dayOfTheWeek, let time):
            if let index = self.getIndex(of: dayOfTheWeek) {
                newState.store.appearanceDays[index].openingHours.startTime = time
            }
            
        case .setEndTime(let dayOfTheWeek, let time):
            if let index = self.getIndex(of: dayOfTheWeek) {
                newState.store.appearanceDays[index].openingHours.endTime = time
            }
            
        case .setLocation(let dayOfTheWeek, let location):
            if let index = self.getIndex(of: dayOfTheWeek) {
                newState.store.appearanceDays[index].locationDescription = location
            }
            
        case .pop:
            self.popPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func getIndex(of dayOfTheWeek: DayOfTheWeek) -> Int? {
        return self.currentState.store.appearanceDays.firstIndex {
            $0.dayOfTheWeek == dayOfTheWeek
        }
    }
    
    private func updateStore(store: Store) -> Observable<Mutation> {
        return self.storeService.updateStore(store: store)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.globalState.updateStorePublisher.onNext(store)
                logManager.sendEvent(.init(
                    screen: .editSchedule,
                    eventName: .editSchedule,
                    extraParameters: [.storeId: currentState.store.id]
                ))
            })
            .map { _ in Mutation.pop }
            .catch {
                return .merge([
                    .just(.showLoading(isShow: false)),
                    .just(.showErrorAlert($0))
                ])
            }
    }
}
