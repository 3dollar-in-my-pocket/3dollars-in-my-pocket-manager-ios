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
    private let authRepository: AuthRepository
    private let preference: Preference
    private let logManager: LogManagerProtocol
    
    init(
        authRepository: AuthRepository = AuthRepositoryImpl(),
        preference: Preference = .shared,
        logManager: LogManagerProtocol
    ) {
        self.authRepository = authRepository
        self.preference = preference
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
        return Observable.create { observer in
            let task = Task { [weak self] in
                guard let self else {
                    observer.onError(BaseError.nilValue)
                    return
                }
                
                let request = BossLogOutRequest(fcmToken: preference.fcmToken)
                do {
                    _ = try await authRepository.logout(request: request).get()
                    
                    logManager.sendEvent(.init(
                        screen: .waiting,
                        eventName: .logout,
                        extraParameters: [.userId: preference.userId]
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
}
