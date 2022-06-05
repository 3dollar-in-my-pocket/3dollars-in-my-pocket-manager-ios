import UIKit

import ReactorKit
import RxRelay

final class EditMenuReactor: BaseReactor, Reactor {
    enum Action {
        case tapBackButton
        case addPhoto(index: Int, photo: UIImage)
        case inputMenuName(index: Int, name: String)
        case inputMenuPrice(index: Int, price: Int)
        case tapDeleteButton
        case tapDeleteMenuButton(index: Int)
        case tapAddMenuButton
        case tapSaveButton
    }
    
    enum Mutation {
        case showSaveAlert
        case setPhoto(index: Int, photo: UIImage)
        case setMenuName(index: Int, name: String)
        case setMenuPrice(index: Int, price: Int)
        case deleteMenu(index: Int)
        case addMenu
        case toggleDeleteMode
        case pop
        case refreshSaveButtonEnable
        case showLoading(isShow: Bool)
        case showErrorAlert(error: Error)
    }
    
    struct State {
        var store: Store
        var originalMenuCount: Int
        var isAddMenuButtonHidden: Bool
        var isEnableSaveButton: Bool
        ///  변경되거나 추가된 이미지들
        var newPhotos: [(Int, UIImage)]
        var isDeleteMode: Bool
    }
    
    let initialState: State
    let popPublisher = PublishRelay<Void>()
    let showSavePublisher = PublishRelay<Void>()
    private let storeService: StoreServiceType
    private let imageService: ImageServiceType
    private let globalState: GlobalState
    
    init(
        store: Store,
        storeService: StoreServiceType,
        imageService: ImageServiceType,
        globalState: GlobalState
    ) {
        self.storeService = storeService
        self.imageService = imageService
        self.globalState = globalState
        
        var newStore = store
        if store.menus.isEmpty {
            newStore.menus.append(Menu())
        }
        
        self.initialState = .init(
            store: newStore,
            originalMenuCount: store.menus.count,
            isAddMenuButtonHidden: store.menus.count == 20,
            isEnableSaveButton: false,
            newPhotos: [],
            isDeleteMode: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapBackButton:
            if self.initialState.store != self.currentState.store {
                return .just(.showSaveAlert)
            } else {
                return .just(.pop)
            }
            
        case .addPhoto(let index, let photo):
            return .just(.setPhoto(index: index, photo: photo))
            
        case .inputMenuName(let index, let name):
            return .merge([
                .just(.setMenuName(index: index, name: name)),
                .just(.refreshSaveButtonEnable)
            ])
            
        case .inputMenuPrice(let index, let price):
            return .merge([
                .just(.setMenuPrice(index: index, price: price)),
                .just(.refreshSaveButtonEnable)
            ])
            
        case .tapDeleteButton:
            return .just(.toggleDeleteMode)
            
        case .tapDeleteMenuButton(let index):
            return .merge([
                .just(.deleteMenu(index: index)),
                .just(.refreshSaveButtonEnable)
            ])
                
            
        case .tapAddMenuButton:
            return .merge([
                .just(.addMenu),
                .just(.refreshSaveButtonEnable)
            ])
                
            
        case .tapSaveButton:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.updateStore(
                    store: self.currentState.store,
                    newPhotos: self.currentState.newPhotos
                ),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .showSaveAlert:
            self.showSavePublisher.accept(())
            
        case .setPhoto(let index, let photo):
            newState.store.menus[index].photo = photo
            if let index = state.newPhotos.firstIndex(where: { $0.0 == index }) {
                newState.newPhotos[index] = (index, photo)
            } else {
                newState.newPhotos.append((index, photo))
            }
            
        case .setMenuName(let index, let name):
            newState.store.menus[index].name = name
            
        case .setMenuPrice(let index, let price):
            newState.store.menus[index].price = price
            
        case .deleteMenu(let index):
            newState.store.menus.remove(at: index)
            newState.isAddMenuButtonHidden = newState.store.menus.count == 20
            
        case .addMenu:
            newState.store.menus.append(Menu())
            newState.isAddMenuButtonHidden = newState.store.menus.count == 20
            
        case .toggleDeleteMode:
            newState.isDeleteMode.toggle()
            
        case .pop:
            self.popPublisher.accept(())
            
        case .refreshSaveButtonEnable:
            newState.isEnableSaveButton = newState.store !=  self.initialState.store
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func updateStore(store: Store, newPhotos: [(Int, UIImage)]) -> Observable<Mutation> {
        if newPhotos.isEmpty {
            return self.storeService.updateStore(store: self.currentState.store)
                .map { _ in Mutation.pop }
                .catch {
                    .merge([
                        .just(.showErrorAlert(error: $0)),
                        .just(.showLoading(isShow: false))
                    ])
                }
        } else {
            let images = newPhotos.map { $0.1 }
            
            return self.imageService.uploadImages(images: images, fileType: .menu)
                .flatMap { response -> Observable<Mutation> in
                    var newStore = store
                    let imageURLs = response.map { $0.imageUrl }
                    let newPhotoIndex = newPhotos.map { $0.0 }
                    
                    for index in imageURLs.indices {
                        newStore.menus[newPhotoIndex[index]].imageUrl = imageURLs[index]
                    }
                    
                    return self.storeService.updateStore(store: newStore)
                        .map { _ in Mutation.pop }
                }
                .catch {
                    .merge([
                        .just(.showErrorAlert(error: $0)),
                        .just(.showLoading(isShow: false))
                    ])
                }
        }
    }
    
    private func getValidStore(store: Store) -> Store {
        var newStore = store
        
        newStore.menus = newStore.menus.filter { $0.isValid }
        return newStore
    }
}
