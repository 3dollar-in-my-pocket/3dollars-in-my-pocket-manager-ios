import ReactorKit
import RxSwift
import RxCocoa

final class SplashReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case goToSignin
        case goToMain
        case goToWaiting
        case setFeedbackTypes([FeedbackType])
        case showErrorAlert(Error)
    }
    
    struct State {
        
    }
    
    let initialState = State()
    let goToSigninPublisher = PublishRelay<Void>()
    let goToMainPublisher = PublishRelay<Void>()
    let goToWaitingPublisher = PublishRelay<Void>()
    private let authService: AuthServiceType
    private let feedbackService: FeedbackServiceType
    private let userDefaultsUtils: Preference
    private let context: SharedContext
    
    init(
        authService: AuthServiceType,
        feedbackService: FeedbackServiceType,
        userDefaultsUtils: Preference,
        context: SharedContext
    ) {
        self.authService = authService
        self.feedbackService = feedbackService
        self.userDefaultsUtils = userDefaultsUtils
        self.context = context
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            if self.userDefaultsUtils.userToken.isEmpty {
                return .merge([
                    self.fetchFeedbackTypes(),
                    .just(.goToSignin)
                ])
                
            } else {
                return .merge([
                    self.fetchFeedbackTypes(),
                    self.fetchUserInfo()
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .goToSignin:
            self.goToSigninPublisher.accept(())
            
        case .goToMain:
            self.goToMainPublisher.accept(())
            
        case .goToWaiting:
            self.goToWaitingPublisher.accept(())
            
        case .setFeedbackTypes(let feedbackTypes):
            self.context.feedbackTypes = feedbackTypes
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return state
    }
    
    private func fetchUserInfo() -> Observable<Mutation> {
        return self.authService.fetchMyInfo()
            .map{ _ in .goToMain }
            .catch { error in
                if let httpError = error as? HTTPError {
                    switch httpError {
                    case .unauthorized: // 세션 만료 => 로그인 필요
                        return .just(.goToSignin)
                        
                    case .forbidden: // 신청 대기중
                        return .just(.goToWaiting)
                        
                    case .notFound: // 회원 탈퇴 및 반려
                        return .just(.goToSignin)
                        
                    default:
                        return .just(.showErrorAlert(error))
                    }
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
    
    private func fetchFeedbackTypes() -> Observable<Mutation> {
        return self.feedbackService.fetchFeedbackTypes()
            .map { $0.map(FeedbackType.init(response:)) }
            .map { .setFeedbackTypes($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
