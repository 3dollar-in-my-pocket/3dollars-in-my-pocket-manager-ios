import RxSwift
import RxCocoa
import ReactorKit

final class EditIntroductionReactor: Reactor {
    enum Action {
        case inputText(String)
        case tapEditButton
    }
    
    enum Mutation {
        case setIntroduction(String)
        case setEditButtonEnable(Bool)
        case popWishIntroduction(String)
    }
    
    struct State {
        var introduction: String?
        var isEditButtonEnable: Bool
    }
    
    let initialState: State
    let popupWithIntroductionPublisher = PublishRelay<String>()
    
    init(introduction: String?) {
        self.initialState = State(
            introduction: introduction,
            isEditButtonEnable: introduction?.isEmpty == false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputText(let text):
            return .merge([
                .just(.setIntroduction(text)),
                .just(.setEditButtonEnable(!text.isEmpty))
            ])
            
        case .tapEditButton:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setIntroduction(let introduction):
            newState.introduction = introduction
            
        case .setEditButtonEnable(let isEnable):
            newState.isEditButtonEnable = isEnable
            
        case .popWishIntroduction(let introduction):
            self.popupWithIntroductionPublisher.accept(introduction)
        }
        
        return newState
    }
}
