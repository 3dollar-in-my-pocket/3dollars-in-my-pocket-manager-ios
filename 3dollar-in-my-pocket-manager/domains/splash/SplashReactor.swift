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
        case showErrorAlert(Error)
    }
    
    struct State {
        
    }
    
    let initialState = State()
    let goToSigninPublisher = PublishRelay<Void>()
    let goToMainPublisher = PublishRelay<Void>()
    let goToWaitingPublisher = PublishRelay<Void>()
    private let authService: AuthServiceType
    private let userDefaultsUtils: UserDefaultsUtils
    
    
    init(authService: AuthServiceType, userDefaultsUtils: UserDefaultsUtils) {
        self.authService = authService
        self.userDefaultsUtils = userDefaultsUtils
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            if self.userDefaultsUtils.userToken.isEmpty {
                return .just(.goToSignin)
            } else {
                return self.fetchUserInfo()
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
}
