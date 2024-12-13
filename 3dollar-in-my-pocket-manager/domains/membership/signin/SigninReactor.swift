import ReactorKit
import RxSwift
import RxCocoa

final class SigninReactor: BaseReactor, Reactor {
    enum Constant {
        static let maxTapCountOfLogo = 5
    }
    
    enum Action {
        case tapLogo
        case tapSignInButton(socialType: SocialType)
        case signinDemo(code: String)
    }
    
    enum Mutation {
        case increaseTapLogoCount
        case clearTapLogoCount
        case pushSignUp(socialType: SocialType, token: String, name: String?)
        case goToWaiting
        case goToMain
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
        case route(Route)
    }
    
    struct State {
        var logoClickCount = 0
        var name: String?
        @Pulse var route: Route?
    }
    
    enum Route {
        case presentCodeAlert
    }
    
    var initialState = State()
    let pushSignUpPublisher = PublishRelay<(SocialType, String, String?)>()
    let goToWaitingPublisher = PublishRelay<Void>()
    let goToMainPublisher = PublishRelay<Void>()
    private let kakaoSignInManager: KakaoSignInManagerProtocol
    private let appleSignInManager: AppleSignInManagerProtocol
    private let authService: AuthServiceType
    private let deviceService: DeviceServiceType
    private var userDefaultsUtils: Preference
    private let logManager: LogManager
    
    init(
        kakaoManager: KakaoSignInManagerProtocol,
        appleSignInManager: AppleSignInManagerProtocol,
        authService: AuthServiceType,
        deviceService: DeviceServiceType,
        userDefaultsUtils: Preference,
        logManager: LogManager
    ) {
        self.kakaoSignInManager = kakaoManager
        self.appleSignInManager = appleSignInManager
        self.authService = authService
        self.deviceService = deviceService
        self.userDefaultsUtils = userDefaultsUtils
        self.logManager = logManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapLogo:
            if currentState.logoClickCount >= Constant.maxTapCountOfLogo - 1 {
                return .merge([
                    .just(.route(.presentCodeAlert)),
                    .just(.clearTapLogoCount)
                ])
            } else {
                return .just(.increaseTapLogoCount)
            }
            
        case .tapSignInButton(let socialType):
            return self.signinWithSocial(socialType: socialType)
            
        case .signinDemo(let code):
            return signinDemo(code: code)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .increaseTapLogoCount:
            newState.logoClickCount += 1
            
        case .clearTapLogoCount:
            newState.logoClickCount = 0
            
        case .pushSignUp(let socialType, let token, let name):
            self.pushSignUpPublisher.accept((socialType, token, name))
            
        case .goToWaiting:
            self.goToWaitingPublisher.accept(())
            
        case .goToMain:
            self.goToMainPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
            
        case .route(let route):
            newState.route = route
        }
        
        return newState
    }
    
    private func signinWithSocial(socialType: SocialType) -> Observable<Mutation> {
        switch socialType {
        case .apple:
            return self.appleSignInManager.signIn()
                .flatMap { [weak self] signInResult -> Observable<Mutation> in
                    guard let self = self else { return .error(BaseError.unknown) }
                    
                    return self.signin(socialType: socialType, token: signInResult.token, name: signInResult.name)
                }
            
        case .kakao:
            return self.kakaoSignInManager.signIn()
                .flatMap { [weak self] token -> Observable<Mutation> in
                    guard let self = self else { return .error(BaseError.unknown) }
                    
                    return self.signin(socialType: socialType, token: token)
                }
            
        case .google, .unknown:
            return .empty()
        }
    }
    
    private func signin(socialType: SocialType, token: String, name: String? = nil) -> Observable<Mutation> {
        let signinObservable = self.authService.login(socialType: socialType, token: token)
            .do(onNext: { [weak self] response in
                self?.userDefaultsUtils.userId = response.bossId
                self?.userDefaultsUtils.userToken = response.token
                self?.logManager.setUserId(response.bossId)
                self?.logManager.sendEvent(.init(
                    screen: .signin,
                    eventName: .signin, 
                    extraParameters: [.userId: response.bossId]
                ))
            })
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return .zip(self.fetchUserInfo(), self.registerDevice()) { mutation, _ in
                    return mutation
                }
            }
            .catch { error -> Observable<Mutation> in
                if let httpError = error as? HTTPError {
                    switch httpError {
                    case .notFound:
                        return .just(.pushSignUp(socialType: socialType, token: token, name: name))
                        
                    case .forbidden:
                        return .just(.goToWaiting)
                        
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
    
    private func fetchUserInfo() -> Observable<Mutation> {
        return self.authService.fetchMyInfo()
            .map{ _ in .goToMain }
            .catch { error in
                if let httpError = error as? HTTPError {
                    switch httpError {
                    case .forbidden: // 신청 대기중
                        return .just(.goToWaiting)
                        
                    default:
                        return .just(.showErrorAlert(error))
                    }
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
    
    private func registerDevice() -> Observable<Void> {
        return self.deviceService.registerDevice()
    }
    
    private func signinDemo(code: String) -> Observable<Mutation> {
        return authService.signinDemo(code: code)
            .do(onNext: { [weak self] response in
                self?.userDefaultsUtils.userId = response.bossId
                self?.userDefaultsUtils.userToken = response.token
                self?.logManager.setUserId(response.bossId)
                self?.logManager.sendEvent(.init(
                    screen: .signin,
                    eventName: .signin,
                    extraParameters: [.userId: response.bossId]
                ))
            })
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return .zip(self.fetchUserInfo(), self.registerDevice()) { mutation, _ in
                    return mutation
                }
            }
            .catch { error -> Observable<Mutation> in
                return .merge([
                    .just(.showErrorAlert(error)),
                    .just(.showLoading(isShow: false))
                ])
            }
    }
}
