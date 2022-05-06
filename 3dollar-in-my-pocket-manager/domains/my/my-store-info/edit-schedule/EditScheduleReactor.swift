import Foundation

import ReactorKit
import RxSwift
import RxCocoa

final class EditScheduleReactor:  BaseReactor, Reactor {
    enum Action {
        case tapDayOfTheWeek(DayOfTheWeek)
        case inputStartTime(day: DayOfTheWeek, time: Date)
        case inputEndTime(day: DayOfTheWeek, time: Date)
        case inputLocation(day: DayOfTheWeek, location: String)
    }
    
    enum Mutation {
        case addDayOfWeek(DayOfTheWeek)
        case removeDayOfWeek(DayOfTheWeek)
        case setStartTime(day: DayOfTheWeek, time: Date)
        case setEndTime(day: DayOfTheWeek, time: Date)
        case setLocation(day: DayOfTheWeek, location: String)
        case pop
    }
    
    struct State {
        var store: Store
    }
    
    let initialState: State
    let popPublisher = PublishRelay<Void>()
    private let storeService: StoreServiceType
    private let globlaState: GlobalState
    
    init(
        store: Store,
        storeService: StoreServiceType,
        globalState: GlobalState
    ) {
        self.initialState = State(store: store)
        self.storeService = storeService
        self.globlaState = globalState
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
                newState.store.appearanceDays[index].openingHours.startTime
                = LocalTimeRes(date: time)
            }
            
        case .setEndTime(let dayOfTheWeek, let time):
            if let index = self.getIndex(of: dayOfTheWeek) {
                newState.store.appearanceDays[index].openingHours.endTime
                = LocalTimeRes(date: time)
            }
            
        case .setLocation(let dayOfTheWeek, let location):
            if let index = self.getIndex(of: dayOfTheWeek) {
                newState.store.appearanceDays[index].locationDescription = location
            }
            
        case .pop:
            self.globlaState.updateStorePublisher.onNext(self.currentState.store)
            self.popPublisher.accept(())
        }
        
        return newState
    }
    
    private func getIndex(of dayOfTheWeek: DayOfTheWeek) -> Int? {
        return self.currentState.store.appearanceDays.firstIndex {
            $0.dayOfTheWeek == dayOfTheWeek
        }
    }
}
