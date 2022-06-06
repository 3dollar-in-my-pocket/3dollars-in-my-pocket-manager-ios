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
        case deleteAllMenu
        case tapDeleteMenuButton(index: Int)
        case tapAddMenuButton
        case tapSaveButton
    }
    
    enum Mutation {
        case showSaveAlert
        case showDeleteAllAlert
        case setStore(store: Store)
        case setMenus(menus: [Menu])
        case setPhoto(index: Int, photo: UIImage)
        case setMenuName(index: Int, name: String)
        case setMenuPrice(index: Int, price: Int)
        case deleteMenu(index: Int)
        case deleteAllMenu
        case addMenu
        case toggleDeleteMode
        case pop
        case setSaveButtonEnable(isEnable: Bool)
        case refreshSaveButtonEnable
        case showLoading(isShow: Bool)
        case showErrorAlert(error: Error)
    }
    
    struct State {
        var store: Store
        var originalMenuCount: Int
        var isAddMenuButtonHidden: Bool
        var isEnableSaveButton: Bool
        var isDeleteMode: Bool
    }
    
    let initialState: State
    let popPublisher = PublishRelay<Void>()
    let showSavePublisher = PublishRelay<Void>()
    let showDeleteAllAlertPublisher = PublishRelay<Void>()
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
            
        case .deleteAllMenu:
            return .merge([
                .just(.deleteAllMenu),
                .just(.refreshSaveButtonEnable)
            ])
                
            
        case .tapDeleteButton:
            if self.currentState.isDeleteMode {
                return .just(.showDeleteAllAlert)
            } else {
                let validStore = self.getValidStore(store: self.currentState.store)
                
                return .merge([
                    .just(.setStore(store: validStore)),
                    .just(.toggleDeleteMode),
                    .just(.setSaveButtonEnable(isEnable: true))
                ])
            }
            
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
            if self.currentState.isDeleteMode {
                if self.currentState.store.menus.isEmpty {
                    return .merge([
                        .just(.setMenus(menus: [Menu()])),
                        .just(.toggleDeleteMode)
                    ])
                } else {
                    return .just(.toggleDeleteMode)
                }
            } else {
                let validStore = self.getValidStore(store: self.currentState.store)
                
                return .concat([
                    .just(.showLoading(isShow: true)),
                    self.updateStore(store: validStore),
                    .just(.showLoading(isShow: false))
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .showSaveAlert:
            self.showSavePublisher.accept(())
            
        case .showDeleteAllAlert:
            self.showDeleteAllAlertPublisher.accept(())
            
        case .setStore(let store):
            newState.store = store
            
        case .setMenus(let menus):
            newState.store.menus = menus
            
        case .setPhoto(let index, let photo):
            newState.store.menus[index].photo = photo
            
        case .setMenuName(let index, let name):
            newState.store.menus[index].name = name
            
        case .setMenuPrice(let index, let price):
            newState.store.menus[index].price = price
            
        case .deleteMenu(let index):
            newState.store.menus.remove(at: index)
            newState.isAddMenuButtonHidden = newState.store.menus.count == 20
            
        case .deleteAllMenu:
            newState.store.menus = []
            
        case .addMenu:
            newState.store.menus.append(Menu())
            newState.isAddMenuButtonHidden = newState.store.menus.count == 20
            
        case .toggleDeleteMode:
            newState.isDeleteMode.toggle()
            newState.isAddMenuButtonHidden = newState.isDeleteMode
            
        case .pop:
            self.popPublisher.accept(())
            
        case .setSaveButtonEnable(let isEnable):
            newState.isEnableSaveButton = isEnable
            
        case .refreshSaveButtonEnable:
            newState.isEnableSaveButton = newState.store !=  self.initialState.store
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func updateStore(store: Store) -> Observable<Mutation> {
        let newPhotos = store.menus
            .filter { $0.photo != nil }
            .compactMap { $0.photo }
        let newPhotosIndex = store.menus
            .filter { $0.photo != nil }
            .compactMap { store.menus.firstIndex(of: $0) }
        
        if newPhotos.isEmpty {
            return self.storeService.updateStore(store: store)
                .do(onNext: { [weak self] _ in
                    self?.globalState.updateStorePublisher.onNext(store)
                })
                .map { _ in Mutation.pop }
                .catch {
                    .merge([
                        .just(.showErrorAlert(error: $0)),
                        .just(.showLoading(isShow: false))
                    ])
                }
        } else {
            return self.imageService.uploadImages(images: newPhotos, fileType: .menu)
                .flatMap { response -> Observable<Mutation> in
                    var newStore = store
                    let imageURLs = response.map { $0.imageUrl }
                    
                    for index in imageURLs.indices {
                        newStore.menus[newPhotosIndex[index]].imageUrl = imageURLs[index]
                    }
                    
                    return self.storeService.updateStore(store: newStore)
                        .do(onNext: { [weak self] _ in
                            self?.globalState.updateStorePublisher.onNext(newStore)
                        })
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
