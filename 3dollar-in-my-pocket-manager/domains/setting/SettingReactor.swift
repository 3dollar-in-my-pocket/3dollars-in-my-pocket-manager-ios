import ReactorKit
import RxSwift
import RxCocoa

final class SettingReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapInquiry
        case tapLogout
        case tapSignout
    }
    
    enum Mutation {
        case setUser(user: User)
        case goToSignin
        case goToKakaotalkChannel
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var user: User
    }
    
    let initialState: State
    let goToSigninPublisher = PublishRelay<Void>()
    let goToKakaotalkChannel = PublishRelay<Void>()
    private let authService: AuthServiceType
    private let userDefaults: UserDefaultsUtils
    
    init(
        authService: AuthServiceType,
        userDefaults: UserDefaultsUtils,
        state: State = State(user: User())
    ) {
        self.authService = authService
        self.userDefaults = userDefaults
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchMyInfo()
            
        case .tapInquiry:
            return .just(.goToKakaotalkChannel)
            
        case .tapLogout:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.logout(),
                .just(.showLoading(isShow: false))
            ])
            
        case .tapSignout:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.signout(),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setUser(let user):
            newState.user = user
            
        case .goToSignin:
            self.goToSigninPublisher.accept(())
            
        case .goToKakaotalkChannel:
            self.goToKakaotalkChannel.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func fetchMyInfo() -> Observable<Mutation> {
        return self.authService.fetchMyInfo()
            .map(User.init(response:))
            .map { .setUser(user: $0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func logout() -> Observable<Mutation> {
        return self.authService.logout()
            .do(onNext: { [weak self] _ in
                self?.userDefaults.clear()
            })
            .map { _ in .goToSignin }
            .catch {
                .merge([
                    .just(.showErrorAlert($0)),
                    .just(.showLoading(isShow: false))
                ])
                
            }
    }
    
    private func signout() -> Observable<Mutation> {
        return self.authService.signout()
            .do(onNext: { [weak self] _ in
                self?.userDefaults.clear()
            })
            .map { _ in .goToSignin }
            .catch {
                .merge([
                    .just(.showErrorAlert($0)),
                    .just(.showLoading(isShow: false))
                ])
                
            }
    }
}
