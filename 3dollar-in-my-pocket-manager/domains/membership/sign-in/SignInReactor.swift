import ReactorKit
import RxSwift
import RxCocoa

final class SignInReactor: Reactor {
    enum Action {
        case tapSignInButton(socialType: SocialType)
    }
    
    enum Mutation {
        case pushSignUp(socialType: SocialType, token: String)
        case pushWait
        case goToMain
    }
    
    struct State {
        
    }
    
    var initialState = State()
    let pushSignUpPublisher = PublishRelay<(SocialType, String)>()
    let pushWaitPublisher = PublishRelay<String>()
    let goToMainPublisher = PublishRelay<Void>()
    private let kakaoSignInManager: KakaoSignInManagerProtocol
    private let appleSignInManager: AppleSignInManagerProtocol
    private let authService: AuthServiceProtocol
    
    init(
        kakaoManager: KakaoSignInManagerProtocol,
        appleSignInManager: AppleSignInManagerProtocol,
        authService: AuthServiceProtocol
    ) {
        self.kakaoSignInManager = kakaoManager
        self.appleSignInManager = appleSignInManager
        self.authService = authService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}
