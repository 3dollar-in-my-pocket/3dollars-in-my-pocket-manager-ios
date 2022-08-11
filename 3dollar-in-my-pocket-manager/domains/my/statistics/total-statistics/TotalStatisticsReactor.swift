import ReactorKit
import RxSwift
import RxCocoa

final class TotalStatisticsReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case refresh
        case viewWillAppear
    }
    
    enum Mutation {
        case setStatistics([Statistic])
        case updateTableViewHeight([Statistic])
        case setReviewTotalCount(Int)
        case showErrorAlert(Error)
    }
    
    struct State {
        var statistics: [Statistic] = []
        var reviewTotalCount: Int = 0
    }
    
    let initialState = State()
    let updateTableViewHeightPublisher = PublishRelay<[Statistic]>()
    private let feedbackService: FeedbackServiceType
    private let globalState: GlobalState
    private var userDefaults: UserDefaultsUtils
    
    init(
        feedbackService: FeedbackServiceType,
        globalState: GlobalState,
        userDefaults: UserDefaultsUtils
    ) {
        self.feedbackService = feedbackService
        self.globalState = globalState
        self.userDefaults = userDefaults
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchStatistics()
            
        case .refresh:
            return self.fetchStatistics()
            
        case .viewWillAppear:
            return .just(.updateTableViewHeight(self.currentState.statistics))
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge([
            mutation,
            self.globalState.updateReviewCountPublisher
                .map { .setReviewTotalCount($0) }
        ])
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStatistics(let statistics):
            newState.statistics = statistics
            
        case .updateTableViewHeight(let statistics):
            self.updateTableViewHeightPublisher.accept(statistics)
            
        case .setReviewTotalCount(let totalCount):
            newState.reviewTotalCount = totalCount
            self.globalState.updateReviewCountPublisher.onNext(totalCount)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func fetchStatistics() -> Observable<Mutation> {
        let storeId = self.userDefaults.storeId
        
        return self.feedbackService.fetchTotalStatistics(storeId: storeId)
            .map { $0.map(Statistic.init(response:)).sorted() }
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
