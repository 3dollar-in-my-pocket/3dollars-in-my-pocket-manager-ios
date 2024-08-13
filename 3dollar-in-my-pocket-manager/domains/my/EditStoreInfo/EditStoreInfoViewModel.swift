import UIKit
import Combine

import ReactorKit
import RxSwift
import RxCocoa

extension EditStoreInfoViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let inputStoreName = PassthroughSubject<String, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let deselectCategory = PassthroughSubject<Int, Never>()
        let addPhotos = PassthroughSubject<[UIImage], Never>()
        let didTapAddPhoto = PassthroughSubject<Void, Never>()
        let deletePhoto = PassthroughSubject<Int, Never>()
        let inputSNS = PassthroughSubject<String, Never>()
        let didTapSave = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let store: CurrentValueSubject<BossStoreInfoResponse, Never>
        let categories = CurrentValueSubject<[StoreFoodCategoryResponse], Never>([])
        let isEnableSaveButton = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Config {
        let store: BossStoreInfoResponse
    }
    
    enum Route {
        case showErrorAlert(Error)
        case presentCategoryBottomSheet
        case pop
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let categoryRepository: CategoryRepository
        let imageRepository: ImageRepository
        let logManager: LogManagerProtocol
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            categoryRepository: CategoryRepository = CategoryRepositoryImpl(),
            imageRepository: ImageRepository = ImageRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.storeRepository = storeRepository
            self.categoryRepository = categoryRepository
            self.imageRepository = imageRepository
            self.logManager = logManager
        }
    }
}

final class EditStoreInfoViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private let config: Config
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        self.output = Output(store: .init(config.store))
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, _) in
                owner.fetchCategories()
            }
            .store(in: &cancellables)
        
        input.inputStoreName
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, storeName: String) in
                var store = owner.output.store.value
                store.name = storeName
                owner.output.store.send(store)
                owner.output.isEnableSaveButton.send(owner.validateStore(store: store))
            }
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, index: Int) in
                guard let selectedCategory = owner.output.categories.value[safe: index] else { return }
                
                var store = owner.output.store.value
                store.categories.append(selectedCategory)
            }
            .store(in: &cancellables)
        
        input.deselectCategory
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, index: Int) in
                owner.deselectCategory(index: index)
            }
            .store(in: &cancellables)
        
        // TODO: 이미지 처리 필요
        
        input.inputSNS
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, snsUrl: String) in
                var store = owner.output.store.value
                store.snsUrl = snsUrl
                owner.output.store.send(store)
            }
            .store(in: &cancellables)
    }
    
    private func fetchCategories() {
        Task {
            let result = await dependency.categoryRepository.fetchCategories()
            
            switch result {
            case .success(let categories):
                output.categories.send(categories)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func validateStore(store: BossStoreInfoResponse) -> Bool {
        return store != config.store && store.name.isNotEmpty
    }
    
    private func selectCategory(index: Int) {
        guard let selectedCategory = output.categories.value[safe: index] else { return }
        
        var store = output.store.value
        store.categories.append(selectedCategory)
        output.store.send(store)
    }
    
    private func deselectCategory(index: Int) {
        guard let deselectedCategory = output.categories.value[safe: index] else { return }
        
        var store = output.store.value
        store.categories.removeAll { $0.categoryId == deselectedCategory.categoryId }
        output.store.send(store)
    }
}


final class EditStoreInfoReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case inputStoreName(String)
        case selectCategory(index: Int)
        case deselectCategory(index: Int)
        case selectPhoto(UIImage)
        case inputSNS(String)
        case tapSave
    }
    
    enum Mutation {
        case setStoreName(String)
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
    private let logManager: LogManager
    
    init(
        store: Store,
        storeService: StoreService,
        categoryService: CategoryServiceType,
        imageService: ImageServiceType,
        globalState: GlobalState,
        logManager: LogManager
    ) {
        self.storeService = storeService
        self.categoryService = categoryService
        self.imageService = imageService
        self.globalState = globalState
        self.logManager = logManager
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
    
    private func validate(storeName: String? = nil) -> Bool {
        let storeName = storeName ?? self.currentState.store.name
        
        return !storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                        .do(onNext: { [weak self] _ in
                            guard let self = self else { return }
                            
                            self.globalState.updateStorePublisher.onNext(newStore)
                            logManager.sendEvent(.init(
                                screen: .editStoreInfo,
                                eventName: .editStoreInfo,
                                extraParameters: [.storeId: currentState.store.id]
                            ))
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
