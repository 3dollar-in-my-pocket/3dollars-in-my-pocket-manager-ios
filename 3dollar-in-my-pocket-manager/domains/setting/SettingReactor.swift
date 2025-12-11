import ReactorKit
import RxSwift
import RxCocoa
import FirebaseMessaging
import UIKit

final class SettingReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapFCMToken
        case tapNotificationSwitch(isEnable: Bool)
        case tapLogout
        case tapSignout
    }
    
    enum Mutation {
        case setUser(user: User)
        case setNotificationEnable(isEnable: Bool)
        case showCopySuccessAlert
        case goToSignin
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var user: User
    }
    
    let initialState: State
    let goToSigninPublisher = PublishRelay<Void>()
    let showCopyTokenSuccessAlertPublisher = PublishRelay<Void>()
    private let authService: AuthServiceType
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let preference: Preference
    private let logManager: LogManager
    
    init(
        authService: AuthServiceType,
        authRepository: AuthRepository = AuthRepositoryImpl(),
        userRepository: UserRepository = UserRepositoryImpl(),
        preference: Preference = .shared,
        logManager: LogManager,
        state: State = State(user: User())
    ) {
        self.authService = authService
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.preference = preference
        self.logManager = logManager
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchMyInfo()
            
        case .tapFCMToken:
            return self.fetchFCMToken()
            
        case .tapNotificationSwitch(let isEnable):
            return updateAccountSettings(isEnable: isEnable)
            
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
            
        case .setNotificationEnable(let isEnable):
            newState.user.isNotificationEnable = isEnable
            
        case .showCopySuccessAlert:
            self.showCopyTokenSuccessAlertPublisher.accept(())
            
        case .goToSignin:
            self.goToSigninPublisher.accept(())
            
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
    
    private func fetchFCMToken() -> Observable<Mutation> {
        return .create { observer in
            Messaging.messaging().token { token, error in
                if let error = error {
                    observer.onError(error)
                } else if let token = token {
                    UIPasteboard.general.string = token
                    observer.onNext(.showCopySuccessAlert)
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func logout() -> Observable<Mutation> {
        return Observable.create { observer in
            let task = Task { [weak self] in
                guard let self else {
                    observer.onError(BaseError.nilValue)
                    return
                }
                
                let request = BossLogOutRequest(fcmToken: self.preference.fcmToken)
                do {
                    _ = try await authRepository.logout(request: request).get()
                    
                    logManager.sendEvent(.init(
                        screen: .setting,
                        eventName: .logout,
                        extraParameters: [.userId: currentState.user.bossId]
                    ))
                    preference.clear()
                    
                    observer.onNext(.goToSignin)
                    observer.onCompleted()
                } catch {
                    observer.onNext(.showErrorAlert(error))
                    observer.onNext(.showLoading(isShow: false))
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    private func signout() -> Observable<Mutation> {
        return self.authService.signout()
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                logManager.sendEvent(.init(
                    screen: .setting,
                    eventName: .signout,
                    extraParameters: [.userId: currentState.user.bossId]
                ))
                self.preference.clear()
            })
            .map { _ in .goToSignin }
            .catch {
                .merge([
                    .just(.showErrorAlert($0)),
                    .just(.showLoading(isShow: false))
                ])
                
            }
    }
    
    private func updateAccountSettings(isEnable: Bool) -> Observable<Mutation> {
        let input = BossSettingPatchRequest(enableActivitiesPush: isEnable)
        
        return Observable.create { observer in
            let task = Task { [weak self] in
                guard let self else {
                    observer.onError(BaseError.nilValue)
                    return
                }
                
                do {
                    _ = try await userRepository.updateAccountSettings(input: input).get()
                    observer.onNext(.setNotificationEnable(isEnable: isEnable))
                    observer.onCompleted()
                } catch {
                    observer.onNext(.showErrorAlert(error))
                    observer.onCompleted()
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
