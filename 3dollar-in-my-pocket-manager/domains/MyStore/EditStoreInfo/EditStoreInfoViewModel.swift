import UIKit
import Combine

extension EditStoreInfoViewModel {
    enum Constant {
        static let maxPhotoCount = 10
    }
    
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let inputStoreName = PassthroughSubject<String, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let deselectCategory = PassthroughSubject<Int, Never>()
        let didTapAddPhoto = PassthroughSubject<Void, Never>()
        let addPhotos = PassthroughSubject<[UIImage], Never>()
        let deletePhoto = PassthroughSubject<Int, Never>()
        let inputSNS = PassthroughSubject<String, Never>()
        let inputContactNumber = PassthroughSubject<String, Never>()
        let didTapSave = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .editStoreInfo
        let store: CurrentValueSubject<BossStoreResponse, Never>
        let categories = CurrentValueSubject<[StoreFoodCategoryResponse], Never>([])
        let isEnableSaveButton = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
        let toast = PassthroughSubject<String, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let updatedStore = PassthroughSubject<BossStoreResponse, Never>()
    }
    
    struct Config {
        let store: BossStoreResponse
    }
    
    struct State {
        var store: BossStoreResponse
        var categories: [StoreFoodCategoryResponse] = []
    }
    
    enum Route {
        case showErrorAlert(Error)
        case pop
        case presentPhotoPicker(limit: Int)
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
    private var state: State
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        self.state = State(store: config.store)
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
            .dropFirst()
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, storeName: String) in
                owner.state.store.name = storeName
                owner.output.isEnableSaveButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, index: Int) in
                owner.selectCategory(index: index)
                owner.output.isEnableSaveButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.deselectCategory
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, index: Int) in
                owner.deselectCategory(index: index)
                owner.output.isEnableSaveButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.didTapAddPhoto
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, _) in
                owner.presentPhotoPickerIfNeeded()
            }
            .store(in: &cancellables)
        
        input.addPhotos
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, photos: [UIImage]) in
                owner.addPhotos(photos: photos)
                owner.output.isEnableSaveButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.deletePhoto
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, index: Int) in
                owner.deletePhoto(index: index)
                owner.output.isEnableSaveButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.inputSNS
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, snsUrl: String) in
                owner.state.store.snsUrl = snsUrl
                owner.output.isEnableSaveButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.inputContactNumber
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, contactNumber: String) in
                if contactNumber.isEmpty {
                    owner.state.store.contactsNumbers = []
                } else {
                    owner.state.store.contactsNumbers = [.init(number: contactNumber, description: nil)]
                }
                owner.output.isEnableSaveButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.didTapSave
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewModel, _) in
                owner.editStoreInfo()
            }
            .store(in: &cancellables)
    }
    
    private func fetchCategories() {
        Task {
            let result = await dependency.categoryRepository.fetchCategories()
            
            switch result {
            case .success(let categories):
                state.categories = categories
                output.categories.send(categories)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func validateStore() -> Bool {
        return state.store != config.store 
        && state.store.name.isNotEmpty
        && state.store.categories.isNotEmpty
        && state.store.representativeImages.isNotEmpty
    }
    
    private func selectCategory(index: Int) {
        guard let selectedCategory = state.categories[safe: index] else { return }
        
        state.store.categories.append(selectedCategory)
    }
    
    private func deselectCategory(index: Int) {
        guard let deselectedCategory = state.categories[safe: index] else { return }
        
        state.store.categories.removeAll { $0.categoryId == deselectedCategory.categoryId }
    }
    
    private func presentPhotoPickerIfNeeded() {
        if state.store.representativeImages.count < Constant.maxPhotoCount {
            let limit = Constant.maxPhotoCount - state.store.representativeImages.count
            output.route.send(.presentPhotoPicker(limit: limit))
        } else {
            output.toast.send("edit_store_info.toast.maximum_photo".localized)
        }
    }
    
    private func addPhotos(photos: [UIImage]) {
        let bossStoreImages = photos.map { BossStoreImage(image: $0) }
        state.store.representativeImages.insert(contentsOf: bossStoreImages, at: 0)
        output.store.send(state.store)
    }
    
    private func deletePhoto(index: Int) {
        guard state.store.representativeImages[safe: index].isNotNil else { return }
        state.store.representativeImages.remove(at: index)
        output.store.send(state.store)
    }
    
    private func editStoreInfo() {
        output.showLoading.send(true)
        uploadImagesIfNeeded {
            Task { [weak self] in
                guard let self else { return }
                
                let request = state.store.toPatchRequest()
                let result = await dependency.storeRepository.editStore(storeId: state.store.bossStoreId, request: request)
                
                switch result {
                case .success(_):
                    sendEditStoreLog()
                    output.showLoading.send(false)
                    output.updatedStore.send(state.store)
                    output.toast.send("정보가 업데이트 되었습니다")
                    output.route.send(.pop)
                case .failure(let error):
                    output.showLoading.send(false)
                    output.route.send(.showErrorAlert(error))
                }
            }
        }
    }
    
    private func uploadImagesIfNeeded(completion: @escaping (() -> ())) {
        let images = state.store.representativeImages.compactMap { $0.image }
        
        guard images.isNotEmpty else {
            completion()
            return
        }
        
        Task {
            let imageUploadResult = await dependency.imageRepository.uploadImages(
                images: images, fileType: .store,
                imageType: .jpeg
            )
            
            switch imageUploadResult {
            case .success(let responses):
                for (index, imageUploadResponse) in responses.enumerated() {
                    if state.store.representativeImages[safe: index].isNotNil {
                        state.store.representativeImages[index] = imageUploadResponse
                    }
                }
                completion()
            case .failure(let error):
                output.showLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}

// MARK: Log
extension EditStoreInfoViewModel {
    func sendEditStoreLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .editStoreInfo,
            extraParameters: [.storeId: state.store.bossStoreId])
        )
    }
}
