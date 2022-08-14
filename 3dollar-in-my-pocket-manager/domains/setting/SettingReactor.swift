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
    private let deviceService: DeviceServiceType
    private let userDefaults: UserDefaultsUtils
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(
        authService: AuthServiceType,
        deviceService: DeviceServiceType,
        userDefaults: UserDefaultsUtils,
        analyticsManager: AnalyticsManagerProtocol,
        state: State = State(user: User())
    ) {
        self.authService = authService
        self.deviceService = deviceService
        self.userDefaults = userDefaults
        self.analyticsManager = analyticsManager
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            self.analyticsManager.sendEvent(event: .viewScreen(.setting))
            return self.fetchMyInfo()
            
        case .tapFCMToken:
            return self.fetchFCMToken()
            
        case .tapNotificationSwitch(let isEnable):
            if isEnable {
                return self.deviceService.registerDevice()
                    .map { .setNotificationEnable(isEnable: true) }
                    .catch { .just(.showErrorAlert($0)) }
            } else {
                return self.deviceService.unregisterDevice()
                    .map { .setNotificationEnable(isEnable: false) }
                    .catch { .just(.showErrorAlert($0)) }
            }
            
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
        return self.authService.logout()
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.analyticsManager.sendEvent(
                    event: .logout(userId: self.currentState.user.bossId, screen: .setting)
                )
                self.userDefaults.clear()
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
                guard let self = self else { return }
                
                self.analyticsManager.sendEvent(
                    event: .signout(userId: self.currentState.user.bossId)
                )
                self.userDefaults.clear()
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
