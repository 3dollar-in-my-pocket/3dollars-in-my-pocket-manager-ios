import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class EditStoreInfoReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case inputStoreName(String)
        case inputPhoneNumber(String)
        case selectCategory(index: Int)
        case selectPhoto(UIImage)
        case inputSNS(String)
        case tapSave
    }
    
    enum Mutation {
        case setStoreName(String)
        case setPhoneNumber(String)
        case selectCategory(StoreCategory)
        case deselectCategory(StoreCategory)
        case setCategories([StoreCategory])
        case setPhoto(UIImage)
        case setSNS(String)
        case setSaveButtonEnable(Bool)
        case pop
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var store: Store
        var categories: [StoreCategory]
        var selectedCategories: [StoreCategory]
        var photo: UIImage?
        var isEnableSaveButton: Bool
    }
    
    let initialState: State
    let popPublisher = PublishRelay<Void>()
    private let storeService: StoreServiceType
    private let categoryService: CategoryServiceType
    private let imageService: ImageServiceType
    
    init(
        storeService: StoreService,
        categoryService: CategoryServiceType,
        imageService: ImageServiceType,
        state: State = State(
            store: Store(),
            categories: [],
            selectedCategories: [],
            photo: nil,
            isEnableSaveButton: false
        )
    ) {
        self.storeService = storeService
        self.categoryService = categoryService
        self.imageService = imageService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchCategories()
            
        case .inputStoreName(let storeName):
            return .merge([
                .just(.setStoreName(storeName)),
                .just(.setSaveButtonEnable(self.validate(storeName: storeName)))
            ])
            
        case .inputPhoneNumber(let phoneNumber):
            return .merge([
                .just(.setPhoneNumber(phoneNumber)),
                .just(.setSaveButtonEnable(self.validate(phoneNumber: phoneNumber)))
            ])
            
        case .selectCategory(let index):
            let selectedCategory = self.currentState.categories[index]
            
            if self.currentState.selectedCategories.contains(selectedCategory) {
                return .just(.deselectCategory(selectedCategory))
            } else {
                return .just(.selectCategory(selectedCategory))
            }
            
        case .selectPhoto(let photo):
            return .merge([
                .just(.setPhoto(photo)),
                .just(.setSaveButtonEnable(self.validate(photo: photo)))
            ])
            
        case .inputSNS(let sns):
            return .just(.setSNS(sns))
            
        case .tapSave:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStoreName(let storeName):
            newState.store.name = storeName
            
        case .setPhoneNumber(let phoneNumber):
            newState.store.phoneNumber = phoneNumber
            
        case .selectCategory(let category):
            newState.selectedCategories.append(category)
            
        case .deselectCategory(let category):
            if let targetIndex = state.selectedCategories.firstIndex(of: category) {
                newState.selectedCategories.remove(at: targetIndex)
            }
            
        case .setCategories(let categories):
            newState.categories = categories
            
        case .setPhoto(let photo):
            newState.photo = photo
            
        case .setSNS(let sns):
            newState.store.snsUrl = sns
            
        case .setSaveButtonEnable(let isEnable):
            newState.isEnableSaveButton = isEnable
            
        case .pop:
            self.popPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func fetchCategories() -> Observable<Mutation> {
        return self.categoryService.fetchCategories()
            .map { $0.map(StoreCategory.init(response: )) }
            .map { .setCategories($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func validate(
        storeName: String? = nil,
        phoneNumber: String? = nil,
        photo: UIImage? = nil
    ) -> Bool {
        let storeName = storeName ?? self.currentState.store.name
        let phoneNumber = phoneNumber ??  self.currentState.store.phoneNumber
        let photo = photo ?? self.currentState.photo
        let originalPhoto = self.currentState.store.imageUrl
        
        return !storeName.isEmpty
        && !(phoneNumber ?? "").isEmpty
        && photo != nil
        || !(originalPhoto ?? "").isEmpty
    }
    
    private func updateStore(store: Store, image: UIImage?) -> Observable<Mutation> {
        if let image = image {
            let updateImageAndStoreObservable
            = self.imageService.uploadImage(image: image, fileType: .store)
                .flatMap { [weak self] imageResponse -> Observable<Mutation> in
                    guard let self = self else { return .error(BaseError.unknown) }
                    
                    var newStore = self.currentState.store
                    newStore.imageUrl = imageResponse.imageUrl
                    
                    return self.storeService.updateStore(store: newStore)
                        .map { _ in .pop }
                }
                .catch {
                    return .merge([
                        .just(.showErrorAlert($0)),
                        .just(.showLoading(isShow: false))
                    ])
                }
            
            return .concat([
                .just(.showLoading(isShow: true)),
                updateImageAndStoreObservable,
                .just(.showLoading(isShow: false))
            ])
        } else {
            let updateStoreObservable = self.storeService.updateStore(store: store)
                .map { _ in Mutation.pop }
                .catch {
                    return .merge([
                        .just(.showErrorAlert($0)),
                        .just(.showLoading(isShow: false))
                    ])
                }
            
            return .concat([
                .just(.showLoading(isShow: true)),
                updateStoreObservable,
                .just(.showLoading(isShow: false))
            ])
        }
    }
}
