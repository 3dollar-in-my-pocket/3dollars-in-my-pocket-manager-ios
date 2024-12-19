import Foundation
import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class WaitingReactor: BaseReactor, Reactor {
    enum Action {
        case tapQuestionButton
        case tapLogout
    }
    
    enum Mutation {
        case goToKakaoChanndel
        case goToSignin
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        
    }
    
    let initialState = State()
    let goToKakaoChannelPublisher = PublishRelay<Void>()
    let goToSigninPublisher = PublishRelay<Void>()
    private let authService: AuthServiceType
    private let userDefaults: Preference
    private let logManager: LogManagerProtocol
    
    init(
        authService: AuthServiceType,
        userDefaults: Preference,
        logManager: LogManagerProtocol
    ) {
        self.authService = authService
        self.userDefaults = userDefaults
        self.logManager = logManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapQuestionButton:
            return .just(.goToKakaoChanndel)
        case .tapLogout:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.logout(),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .goToKakaoChanndel:
            self.goToKakaoChannelPublisher.accept(())
            
        case .goToSignin:
            self.goToSigninPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        return state
    }
    
    private func logout() -> Observable<Mutation> {
        let fcmToken = userDefaults.fcmToken
        let deviceRequest = BossLogOutDeviceRequest(pushPlatform: "FCM", pushToken: fcmToken)
        let logoutRequest = BossLogOutRequest(logoutDevice: deviceRequest)
        return self.authService.logout(input: logoutRequest)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                let userId = self.userDefaults.userId
                
                logManager.sendEvent(.init(
                    screen: .waiting,
                    eventName: .logout,
                    extraParameters: [.userId: userId]
                ))
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
