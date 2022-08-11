import Foundation

import ReactorKit
import Base
import RxRelay

final class DailyStatisticsReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case refresh
        case viewWillAppear
        case willDisplayCell(index: Int)
    }
    
    enum Mutation {
        case clearStatisticGroups
        case appendStatisticGroups([StatisticGroup])
        case updateTableViewHeight([StatisticGroup])
        case setTotalReviewCount(Int)
        case showErrorAlert(Error)
    }
    
    struct State {
        var statisticGroups: [StatisticGroup]
        var totalReviewCount: Int
    }
    
    let initialState: State
    let updateTableViewHeightPublisher = PublishRelay<[StatisticGroup]>()
    private let feedbackService: FeedbackServiceType
    private let globalState: GlobalState
    private let userDefaults: UserDefaultsUtils
    private var endDate: Date? = Date()
    private var startDate = Date().addWeek(week: -1)
    
    init(
        feedbackService: FeedbackServiceType,
        globalState: GlobalState,
        userDefaults: UserDefaultsUtils,
        state: State = State(
            statisticGroups: [],
            totalReviewCount: 0
        )
    ) {
        self.feedbackService = feedbackService
        self.globalState = globalState
        self.userDefaults = userDefaults
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .merge([
                self.fetchStatistics(startDate: self.startDate, endDate: self.endDate),
                self.fetchStatistics()
            ])
            
        case .refresh:
            self.resetDate()
            return .concat([
                .just(.clearStatisticGroups),
                self.fetchStatistics(startDate: self.startDate, endDate: self.endDate)
            ])
            
        case .viewWillAppear:
            return .just(.updateTableViewHeight(self.currentState.statisticGroups))
            
        case .willDisplayCell(let index):
            guard index >= self.currentState.statisticGroups.count - 1 else { return .empty() }
            
            return self.fetchStatistics(startDate: self.startDate, endDate: self.endDate)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .clearStatisticGroups:
            newState.statisticGroups = []
            
        case .appendStatisticGroups(let statisticGroup):
            newState.statisticGroups.append(contentsOf: statisticGroup)
            
        case .updateTableViewHeight(let statisticGroups):
            self.updateTableViewHeightPublisher.accept(statisticGroups)
            
        case .setTotalReviewCount(let totalReviewCount):
            newState.totalReviewCount = totalReviewCount
            self.globalState.updateReviewCountPublisher.onNext(totalReviewCount)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func fetchStatistics(
        startDate: Date,
        endDate: Date?
    ) -> Observable<Mutation> {
        guard let endDate = endDate else { return .empty() }
        let storeId = self.userDefaults.storeId
        
        return self.feedbackService.fetchDailyStatistics(
            storeId: storeId,
            startDate: startDate,
            endDate: endDate
        )
        .do(onNext: { [weak self] response in
            guard let self = self else { return }
            if let nextCursor = response.cursor.nextCursor {
                let endDate = DateUtils.toDate(dateString: nextCursor, format: "yyyy-MM-dd")
                
                self.endDate = endDate
                self.startDate = endDate.addWeek(week: -1)
            } else {
                self.endDate = nil
            }
        })
        .flatMap { [weak self] response -> Observable<Mutation> in
            guard let self = self else { return .error(BaseError.unknown) }
            if response.contents.isEmpty {
                return self.fetchStatistics(
                    startDate: self.startDate,
                    endDate: self.endDate
                )
            } else {
                let statisticGroup = response.contents.map(StatisticGroup.init(response:))
                
                return .just(.appendStatisticGroups(statisticGroup))
            }
        }
        .catch { .just(.showErrorAlert($0)) }
    }
    
    private func fetchStatistics() -> Observable<Mutation> {
        let storeId = self.userDefaults.storeId
        
        return self.feedbackService.fetchTotalStatistics(storeId: storeId)
            .map { $0.map(Statistic.init(response:)).sorted() }
            .flatMap { statistics -> Observable<Mutation> in
                let reviewTotalCount = statistics.map { $0.count }.reduce(0, +)
                
                return .just(.setTotalReviewCount(reviewTotalCount))
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func resetDate() {
        self.endDate = Date()
        self.startDate = Date().addWeek(week: -1)
    }
}
