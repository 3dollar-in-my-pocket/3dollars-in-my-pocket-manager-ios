import ReactorKit
import RxSwift
import RxCocoa

final class SigninReactor: BaseReactor, Reactor {
    enum Action {
        case tapSignInButton(socialType: SocialType)
    }
    
    enum Mutation {
        case pushSignUp(socialType: SocialType, token: String)
        case pushWaiting
        case goToMain
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        
    }
    
    var initialState = State()
    let pushSignUpPublisher = PublishRelay<(SocialType, String)>()
    let pushWaitingPublisher = PublishRelay<Void>()
    let goToMainPublisher = PublishRelay<Void>()
    private let kakaoSignInManager: KakaoSignInManagerProtocol
    private let appleSignInManager: AppleSignInManagerProtocol
    private let authService: AuthServiceType
    
    init(
        kakaoManager: KakaoSignInManagerProtocol,
        appleSignInManager: AppleSignInManagerProtocol,
        authService: AuthServiceType
    ) {
        self.kakaoSignInManager = kakaoManager
        self.appleSignInManager = appleSignInManager
        self.authService = authService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapSignInButton(let socialType):
            return self.signinWithSocial(socialType: socialType)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        let newState = state
        
        switch mutation {
        case .pushSignUp(let socialType, let token):
            self.pushSignUpPublisher.accept((socialType, token))
            
        case .pushWaiting:
            self.pushWaitingPublisher.accept(())
            
        case .goToMain:
            self.goToMainPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func signinWithSocial(socialType: SocialType) -> Observable<Mutation> {
        switch socialType {
        case .apple:
            return self.appleSignInManager.signIn()
                .flatMap { [weak self] token -> Observable<Mutation> in
                    guard let self = self else { return .error(BaseError.unknown) }
                    
                    return self.signin(socialType: socialType, token: token)
                }
            
        case .kakao:
            return self.kakaoSignInManager.signIn()
                .flatMap { [weak self] token -> Observable<Mutation> in
                    guard let self = self else { return .error(BaseError.unknown) }
                    
                    return self.signin(socialType: socialType, token: token)
                }
            
        case .google:
            return .empty()
        }
    }
    
    private func signin(socialType: SocialType, token: String) -> Observable<Mutation> {
        let signinObservable = self.authService.login(socialType: socialType, token: token)
            .map { _ in .goToMain }
            .catch { error -> Observable<Mutation> in
                if let httpError = error as? HTTPError {
                    switch httpError {
                    case .notFound:
                        return .just(.pushSignUp(socialType: socialType, token: token))
                        
                    case .forbidden:
                        return .just(.pushWaiting)
                        
                    default:
                        break
                    }
                }
                return .merge([
                    .just(.showErrorAlert(error)),
                    .just(.showLoading(isShow: false))
                ])
            }
        
        return .concat([
            .just(.showLoading(isShow: true)),
            signinObservable,
            .just(.showLoading(isShow: false))
        ])
    }
}
