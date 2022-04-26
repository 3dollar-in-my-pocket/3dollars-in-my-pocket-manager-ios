import RxSwift
import RxCocoa
import ReactorKit

final class EditIntroductionReactor: BaseReactor, Reactor {
    enum Action {
        case inputText(String?)
        case tapEditButton
    }
    
    enum Mutation {
        case setIntroduction(String?)
        case setEditButtonEnable(Bool)
        case popWishIntroduction(String)
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var introduction: String?
        var isEditButtonEnable: Bool
    }
    
    let initialState: State
    let popupWithIntroductionPublisher = PublishRelay<String?>()
    private let storeId: String
    private let storeService: StoreServiceProtocol
    
    init(
        storeId: String,
        storeService: StoreServiceProtocol,
        introduction: String? = nil
    ) {
        self.storeId = storeId
        self.storeService = storeService
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
                .just(.setEditButtonEnable(text?.isEmpty == false))
            ])
            
        case .tapEditButton:
            guard let introduction = self.currentState.introduction else { return .empty() }
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.updateStore(introduction: introduction),
                .just(.showLoading(isShow: false))
            ])
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
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func updateStore(introduction: String) -> Observable<Mutation> {
        return self.storeService.updateStore(
            storeId: self.storeId,
            introduction: introduction
        )
        .map { _ in Mutation.setIntroduction(introduction) }
        .catch {
            return .merge([
                .just(.showLoading(isShow: false)),
                .just(.showErrorAlert($0))
            ])
        }
    }
}
