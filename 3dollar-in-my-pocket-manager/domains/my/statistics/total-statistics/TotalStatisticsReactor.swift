import ReactorKit
import RxSwift
import RxCocoa

final class TotalStatisticsReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setStatistics([Statistic])
        case setReviewTotalCount(Int)
        case showErrorAlert(Error)
    }
    
    struct State {
        var statistics: [Statistic] = []
        var reviewTotalCount: Int = 0
    }
    
    var initialState = State()
    private let feedbackService: FeedbackServiceType
    private var userDefaults: UserDefaultsUtils
    
    init(
        feedbackService: FeedbackServiceType,
        userDefaults: UserDefaultsUtils
    ) {
        self.feedbackService = feedbackService
        self.userDefaults = userDefaults
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchStatistics()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStatistics(let statistics):
            newState.statistics = statistics
            
        case .setReviewTotalCount(let totalCount):
            newState.reviewTotalCount = totalCount
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func fetchStatistics() -> Observable<Mutation> {
        let storeId = self.userDefaults.storeId
        
        return self.feedbackService.fetchTotalStatistics(storeId: storeId)
            .map { $0.map(Statistic.init(response:)) }
            .flatMap { statistics -> Observable<Mutation> in
                let reviewTotalCount = statistics.map { $0.count }.reduce(0, +)
                
                return .merge([
                    .just(.setStatistics(statistics)),
                    .just(.setReviewTotalCount(reviewTotalCount))
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
}
