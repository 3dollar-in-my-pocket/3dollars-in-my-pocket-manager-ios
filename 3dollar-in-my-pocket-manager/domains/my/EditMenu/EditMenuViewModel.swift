import UIKit
import Combine

import ReactorKit
import RxRelay

extension EditMenuViewModel {
    struct Input {
        let didTapBack = PassthroughSubject<Void, Never>()
        let addPhoto = PassthroughSubject<(index: Int, photo: UIImage), Never>()
        let didTapMenuPhoto = PassthroughSubject<Int, Never>()
        let inputMenuName = PassthroughSubject<(index: Int, name: String), Never>()
        let inputMenuPrice = PassthroughSubject<(index: Int, price: Int), Never>()
        let didTapDelete = PassthroughSubject<Void, Never>()
        let didTapDeleteAll = PassthroughSubject<Void, Never>()
        let didTapDeleteMenu = PassthroughSubject<Int, Never>()
        let didTapAddMenu = PassthroughSubject<Void, Never>()
        let didTapSave = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .editMenu
        let menus: CurrentValueSubject<[BossStoreMenu], Never>
        let isEnableSaveButton = CurrentValueSubject<Bool, Never>(false)
        let isDeleteMode = CurrentValueSubject<Bool, Never>(false)
        let showWarning = PassthroughSubject<Int, Never>()
        let updatedStore = PassthroughSubject<BossStoreResponse, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var store: BossStoreResponse
        var isEnableSaveButton = false
        var isDeleteMode = false
    }
    
    struct Config {
        let store: BossStoreResponse
    }
    
    enum Route {
        case pop
        case showSaveAlert
        case showDeleteAllAlert
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let imageRepository: ImageRepository
        let logManager: LogManagerProtocol
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            imageRepository: ImageRepository = ImageRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.storeRepository = storeRepository
            self.imageRepository = imageRepository
            self.logManager = logManager
        }
    }
}

final class EditMenuViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let config: Config
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(menus: .init(config.store.menus))
        self.state = State(store: config.store)
        self.config = config
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapBack
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, _) in
                owner.handleBack()
            }
            .store(in: &cancellables)
        
        input.addPhoto
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, value) in
                let (index, photo) = value
                owner.addPhoto(index: index, photo: photo)
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.inputMenuName
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, value) in
                let (index, name) = value
                owner.setMenuName(index: index, name: name)
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.inputMenuPrice
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, value) in
                let (index, price) = value
                owner.setMenuPrice(index: index, price: price)
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.didTapDelete
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, _) in
                if owner.state.isDeleteMode {
                    owner.output.route.send(.showDeleteAllAlert)
                } else {
                    owner.toggleDeleteMode()
                }
            }
            .store(in: &cancellables)
        
        input.didTapDeleteAll
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, _) in
                owner.deleteAllMenus()
            }
            .store(in: &cancellables)
        
        input.didTapDeleteMenu
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, index: Int) in
                owner.deleteMenu(index: index)
            }
            .store(in: &cancellables)
        
        input.didTapAddMenu
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, _) in
                owner.addMenu()
            }
            .store(in: &cancellables)
        
        input.didTapSave
            .withUnretained(self)
            .sink { (owner: EditMenuViewModel, _) in
                if owner.state.isDeleteMode {
                    owner.toggleDeleteMode()
                } else {
                    if let invalidIndex = owner.getInvalidStoreIndex() {
                        owner.sendWarningLog()
                        owner.output.showWarning.send(invalidIndex)
                    } else {
                        owner.updateStore()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleBack() {
        if state.store != config.store {
            output.route.send(.showSaveAlert)
        } else {
            output.route.send(.pop
            )
        }
    }
    
    private func addPhoto(index: Int, photo: UIImage) {
        guard let targetMenu = state.store.menus[safe: index] else { return }
        
        if targetMenu.image.isNotNil {
            state.store.menus[index].image?.image = photo
        } else {
            state.store.menus[index].image = BossStoreImage(image: photo)
        }
        output.menus.send(state.store.menus)
    }
    
    private func setMenuName(index: Int, name: String) {
        guard state.store.menus[safe: index].isNotNil else { return }
        state.store.menus[index].name = name
    }
    
    private func setMenuPrice(index: Int, price: Int) {
        guard state.store.menus[safe: index].isNotNil else { return }
        state.store.menus[index].price = price
    }
    
    private func toggleDeleteMode() {
        state.isDeleteMode.toggle()
        output.isDeleteMode.send(state.isDeleteMode)
        
        if state.isDeleteMode {
            state.isEnableSaveButton = true
            output.isEnableSaveButton.send(state.isEnableSaveButton)
        } else {
            updateSaveButtonEnable()
        }
    }
    
    private func deleteAllMenus() {
        state.store.menus.removeAll()
        state.isEnableSaveButton = true
        output.menus.send(state.store.menus)
        output.isEnableSaveButton.send(state.isEnableSaveButton)
    }
    
    private func addMenu() {
        let menu = BossStoreMenu()
        state.store.menus.append(menu)
        output.menus.send(state.store.menus)
    }
    
    private func updateSaveButtonEnable() {
        state.isEnableSaveButton = state.store != config.store
        output.isEnableSaveButton.send(state.isEnableSaveButton)
    }
    
    private func getInvalidStoreIndex() -> Int? {
        for (index, menu) in state.store.menus.enumerated() {
            let isImageEmpty = menu.image?.imageUrl == nil && menu.image?.image == nil
            
            if isImageEmpty || menu.name.isEmpty || menu.price == 0 {
                return index
            }
        }
        return nil
    }
    
    private func deleteMenu(index: Int) {
        guard state.store.menus[safe: index].isNotNil else { return }
        state.store.menus.remove(at: index)
        output.menus.send(state.store.menus)
    }
    
    private func updateStore() {
        output.showLoading.send(true)
        uploadImagesIfNeeded {
            Task { [weak self] in
                guard let self else { return }
                
                let request = state.store.toPatchRequest()
                let result = await dependency.storeRepository.editStore(storeId: state.store.bossStoreId, request: request)
                
                switch result {
                case .success(_):
                    sendEditMenuLog()
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
        Task { [weak self] in
            guard let self else { return }
            let urlImageMenus = state.store.menus.filter { $0.image?.imageUrl != nil } // 이미 업로드된 이미지
            var imageMenus = state.store.menus.filter { $0.image?.image != nil } // 업로드 필요한 이미지
            
            guard imageMenus.isNotEmpty else {
                completion()
                return
            }
            
            let imageUploadResult = await dependency.imageRepository.uploadImages(
                images: imageMenus.compactMap { $0.image?.image },
                fileType: .menu,
                imageType: .jpeg
            )
            
            switch imageUploadResult {
            case .success(let imageResponses):
                for (index, imageResponse) in imageResponses.enumerated() {
                    if imageMenus[safe: index].isNotNil {
                        imageMenus[index].image = imageResponse
                    }
                }
                state.store.menus = urlImageMenus + imageMenus
                completion()
            case .failure(let error):
                output.showLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}

// MARK: Log
extension EditMenuViewModel {
    func sendWarningLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .errorInEditingMenu,
            extraParameters: [.storeId: state.store.bossStoreId])
        )
    }
    
    func sendEditMenuLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .editStoreMenu,
            extraParameters: [.storeId: state.store.bossStoreId])
        )
    }
}
