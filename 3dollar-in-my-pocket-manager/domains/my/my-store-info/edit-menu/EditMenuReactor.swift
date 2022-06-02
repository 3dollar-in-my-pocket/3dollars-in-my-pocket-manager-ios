import UIKit

import ReactorKit
import RxRelay

final class EditMenuReactor: BaseReactor, Reactor {
    enum Action {
        case addPhoto(index: Int, photo: UIImage)
        case inputMenuName(index: Int, name: String)
        case inputMenuPrice(index: Int, price: Int)
        case tapDeleteMenuButton(index: Int)
        case tapAddMenuButton
        case tapSaveButton
    }
    
    enum Mutation {
        case setPhoto(index: Int, photoURL: String)
        case setMenuName(index: Int, name: String)
        case setMenuPrice(index: Int, price: Int)
        case deleteMenu(index: Int)
        case addMenu
        case dismiss
        case showLoading(isShow: Bool)
        case showErrorAlert(error: Error)
    }
    
    struct State {
        var store: Store
        var isAddMenuButtonHidden: Bool
        var isEnableSaveButton: Bool
    }
    
    let initialState: State
    let dismissPublisher = PublishRelay<Void>()
    private let storeService: StoreServiceType
    private let imageService: ImageServiceType
    private let globalState: GlobalState
    
    init(
        storeService: StoreServiceType,
        imageService: ImageServiceType,
        globalState: GlobalState,
        state: State = State(
            store: Store(),
            isAddMenuButtonHidden: false,
            isEnableSaveButton: true
        )
    ) {
        self.storeService = storeService
        self.imageService = imageService
        self.globalState = globalState
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .addPhoto(let index, let photo):
            return self.uploadImage(image: photo)
                .map { .setPhoto(index: index, photoURL: $0) }
                .catch { .just(.showErrorAlert(error: $0)) }
            
        case .inputMenuName(let index, let name):
            return .just(.setMenuName(index: index, name: name))
            
        case .inputMenuPrice(let index, let price):
            return .just(.setMenuPrice(index: index, price: price))
            
        case .tapDeleteMenuButton(let index):
            return .just(.deleteMenu(index: index))
            
        case .tapAddMenuButton:
            return .just(.addMenu)
            
        case .tapSaveButton:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.updateStore(store: self.currentState.store),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setPhoto(let index, let photoURL):
            newState.store.menus[index].imageUrl = photoURL
            
        case .setMenuName(let index, let name):
            newState.store.menus[index].name = name
            
        case .setMenuPrice(let index, let price):
            newState.store.menus[index].price = price
            
        case .deleteMenu(let index):
            newState.store.menus.remove(at: index)
            
        case .addMenu:
            newState.store.menus.append(Menu())
            
        case .dismiss:
            self.dismissPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func uploadImage(image: UIImage) -> Observable<String> {
        return self.imageService.uploadImage(image: image, fileType: .menu)
            .map { $0.imageUrl }
    }
    
    private func updateStore(store: Store) -> Observable<Mutation> {
        return self.storeService.updateStore(store: self.currentState.store)
            .map { _ in Mutation.dismiss }
            .catch {
                .merge([
                    .just(.showErrorAlert(error: $0)),
                    .just(.showLoading(isShow: false))
                ])
            }
    }
}
