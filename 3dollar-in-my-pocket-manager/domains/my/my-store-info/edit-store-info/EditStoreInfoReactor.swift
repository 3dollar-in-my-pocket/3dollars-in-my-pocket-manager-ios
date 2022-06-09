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
        case deselectCategory(index: Int)
        case selectPhoto(UIImage)
        case inputSNS(String)
        case tapSave
    }
    
    enum Mutation {
        case setStoreName(String)
        case setPhoneNumber(String)
        case selectCategory(StoreCategory)
        
        /// 기존에 선택되어있는 카테고리 선택해주기
        case selectCategories([Int])
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
        var photo: UIImage?
        var isEnableSaveButton: Bool
    }
    
    let initialState: State
    let popPublisher = PublishRelay<Void>()
    let selectCategoriesPublisher = PublishRelay<[Int]>()
    private let storeService: StoreServiceType
    private let categoryService: CategoryServiceType
    private let imageService: ImageServiceType
    private let globalState: GlobalState
    
    init(
        store: Store,
        storeService: StoreService,
        categoryService: CategoryServiceType,
        imageService: ImageServiceType,
        globalState: GlobalState
    ) {
        self.storeService = storeService
        self.categoryService = categoryService
        self.imageService = imageService
        self.globalState = globalState
        self.initialState = State(
            store: store,
            categories: [],
            photo: nil,
            isEnableSaveButton: false
        )
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
            
            return .just(.selectCategory(selectedCategory))
            
        case .deselectCategory(let index):
            let deselectedCategory = self.currentState.categories[index]
            
            return .just(.deselectCategory(deselectedCategory))
            
        case .selectPhoto(let photo):
            return .just(.setPhoto(photo))
            
        case .inputSNS(let sns):
            return .just(.setSNS(sns))
            
        case .tapSave:
            return self.updateStore(store: self.currentState.store, image: self.currentState.photo)
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
            newState.store.categories.append(category)
            
        case .selectCategories(let indexes):
            self.selectCategoriesPublisher.accept(indexes)
            
        case .deselectCategory(let category):
            if let targetIndex = state.store.categories.firstIndex(of: category) {
                newState.store.categories.remove(at: targetIndex)
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
            .flatMap { [weak self] categories -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                let selectedCategoryIndexes = self.getSelectedCateogriesIndex(categories: categories)
                
                return .merge([
                    .just(.setCategories(categories)),
                    .just(.selectCategories(selectedCategoryIndexes))
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func validate(
        storeName: String? = nil,
        phoneNumber: String? = nil
    ) -> Bool {
        let storeName = storeName ?? self.currentState.store.name
        let phoneNumber = phoneNumber ??  self.currentState.store.phoneNumber
        
        return !storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !(phoneNumber ?? "").isEmpty
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
                        .do(onNext: { _ in
                            self.globalState.updateStorePublisher.onNext(newStore)
                        })
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
                .do(onNext: { [weak self] _ in
                    self?.globalState.updateStorePublisher.onNext(store)
                })
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
    
    private func getSelectedCateogriesIndex(categories: [StoreCategory]) -> [Int] {
        let currentCategories = self.currentState.store.categories
        
        return currentCategories.map { categories.firstIndex(of: $0) ?? 0 }
    }
}
