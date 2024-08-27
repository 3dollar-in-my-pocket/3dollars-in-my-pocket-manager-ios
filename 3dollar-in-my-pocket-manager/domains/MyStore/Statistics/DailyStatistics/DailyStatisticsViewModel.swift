import Foundation
import Combine

extension DailyStatisticsViewModel {
    enum Constant {
        static let dateFormat = "yyyy-MM-dd"
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let viewWillAppear = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let statisticGroups = PassthroughSubject<[FeedbackGroupingDateResponse], Never>()
        let feedbackTypes: [FeedbackTypeResponse]
        let updateContainerHeight = PassthroughSubject<CGFloat, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var statisticGroups: [FeedbackGroupingDateResponse] = []
        var endDate: Date? = Date()
        var startDate = Date().addWeek(week: -1)
        var containerHeight: CGFloat = .zero
    }
    
    enum Route {
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let feedbackRepository: FeedbackRepository
        let preference: Preference
        
        init(
            feedbackRepository: FeedbackRepository = FeedbackRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.feedbackRepository = feedbackRepository
            self.preference = preference
        }
    }
    
    struct Config {
        let feedbackTypes: [FeedbackTypeResponse]
    }
}

final class DailyStatisticsViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state = State()
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(feedbackTypes: config.feedbackTypes)
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: DailyStatisticsViewModel, _) in
                owner.fetchStatistics(
                    startDate: owner.state.startDate,
                    endDate: owner.state.endDate
                )
            }
            .store(in: &cancellables)
        
        input.viewWillAppear
            .withUnretained(self)
            .sink { (owner: DailyStatisticsViewModel, _) in
                owner.output.updateContainerHeight.send(owner.state.containerHeight)
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .withUnretained(self)
            .sink { (owner: DailyStatisticsViewModel, index: Int) in
                guard owner.canLoadMore(index: index) else { return }
                owner.fetchStatistics(
                    startDate: owner.state.startDate,
                    endDate: owner.state.endDate
                )
            }
            .store(in: &cancellables)
    }
    
    private func fetchStatistics(startDate: Date, endDate: Date?) {
        guard let endDate else { return }
        let startDateString = DateUtils.toString(date: startDate, format: Constant.dateFormat)
        let endDateString = DateUtils.toString(date: endDate, format: Constant.dateFormat)
        
        Task {
            let storeId = dependency.preference.storeId
            let result = await dependency.feedbackRepository.fetchDailyStatistics(
                storeId: storeId,
                startDate: startDateString,
                endDate: endDateString
            )
            
            switch result {
            case .success(let response):
                if let nextCursor = response.cursor.nextCursor {
                    let endDate = DateUtils.toDate(dateString: nextCursor, format: Constant.dateFormat)
                    state.endDate = endDate
                    state.startDate = endDate.addWeek(week: -1)
                } else {
                    state.endDate = nil
                }
                
                if response.contents.isEmpty {
                    fetchStatistics(startDate: state.startDate, endDate: state.endDate)
                    updateContainerHeight()
                    return
                } else {
                    state.statisticGroups.append(contentsOf: response.contents)
                    output.statisticGroups.send(state.statisticGroups)
                    updateContainerHeight()
                }
                
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        guard state.statisticGroups.isNotEmpty else { return false }
        return index >= state.statisticGroups.count - 1 && state.endDate.isNotNil
    }
    
    private func updateContainerHeight() {
        var containerHeight: CGFloat
        if state.statisticGroups.isEmpty {
            containerHeight = DailyStatisticsEmptyCell.Layout.size.height
        } else {
            let itemHeight = state.statisticGroups.map {
                DailyStatisticsCell.Layout.calculateHeight($0)
            }.reduce(0, +)
            let space = DailyStatisticsViewController.Layout.space * CGFloat(state.statisticGroups.count - 1)
            
            containerHeight = itemHeight + space
        }
        
        state.containerHeight = containerHeight
        output.updateContainerHeight.send(containerHeight)
    }
}
