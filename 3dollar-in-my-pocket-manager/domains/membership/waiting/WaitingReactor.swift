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
        case presentMailComposer(message: String)
        case goToSignin
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        
    }
    
    let initialState = State()
    let presentMailComposerPublisher = PublishRelay<String>()
    let goToSigninPublisher = PublishRelay<Void>()
    private let authService: AuthServiceType
    private let userDefaults: UserDefaultsUtils
    
    init(
        authService: AuthServiceType,
        userDefaults: UserDefaultsUtils
    ) {
        self.authService = authService
        self.userDefaults = userDefaults
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapQuestionButton:
            let message = "\n\n\n\n----------\n앱 버전: \(self.getAppVersion())\nOS: ios \(self.getiOSVersion())\n"
            
            return .just(.presentMailComposer(message: message))
            
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
        case .presentMailComposer(let message):
            self.presentMailComposerPublisher.accept(message)
            
        case .goToSignin:
            self.goToSigninPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        return state
    }
    
    private func getiOSVersion() -> String {
      return  UIDevice.current.systemVersion
    }
    
    private func getAppVersion() -> String {
      return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
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
}
