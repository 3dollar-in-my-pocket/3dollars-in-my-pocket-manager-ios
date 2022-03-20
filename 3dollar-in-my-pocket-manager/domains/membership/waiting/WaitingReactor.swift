import Foundation
import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class WaitingReactor: Reactor {
    enum Action {
        case tapQuestionButton
    }
    
    enum Mutation {
        case presentMailComposer(message: String)
    }
    
    struct State {
        
    }
    
    let initialState = State()
    let presentMailComposerPublisher = PublishRelay<String>()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapQuestionButton:
            let message = "\n\n\n\n----------\n앱 버전: \(self.getAppVersion())\nOS: ios \(self.getiOSVersion())\n"
            
            return .just(.presentMailComposer(message: message))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .presentMailComposer(let message):
            self.presentMailComposerPublisher.accept(message)
        }
        return state
    }
    
    private func getiOSVersion() -> String {
      return  UIDevice.current.systemVersion
    }
    
    private func getAppVersion() -> String {
      return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
