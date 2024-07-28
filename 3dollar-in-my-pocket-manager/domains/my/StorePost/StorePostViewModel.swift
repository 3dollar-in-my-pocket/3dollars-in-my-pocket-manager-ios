import Combine

extension StorePostViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let cellWillDisplay = PassthroughSubject<Int, Never>()
        let didTapEdit = PassthroughSubject<String, Never>()
        let didTapDelete = PassthroughSubject<String, Never>()
        let didTapWrite = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .storePost
        let postCellViewModelList = CurrentValueSubject<[StorePostCellViewModel], Never>([])
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Dependency {
        let storePostRepository: StorePostRepository
        var userDefaults: UserDefaultsUtils
        let logManager: LogManagerProtocol
        
        init(
            storePostRepository: StorePostRepository = StorePostRepositoryImpl(),
            userDefaults: UserDefaultsUtils = UserDefaultsUtils(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.storePostRepository = storePostRepository
            self.userDefaults = userDefaults
            self.logManager = logManager
        }
    }
    
    struct State {
        var hasMore = true
        var nextCursor: String? = nil
    }
    
    enum Route {
        case pushUpload(viewModel: UploadPostViewModel)
        case pushEdit(viewModel: UploadPostViewModel)
        case showErrorAlert(error: Error)
    }
}

final class StorePostViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    private var cancellables = Set<AnyCancellable>()
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        bind()
    }
    
    private func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: StorePostViewModel, _) in
                owner.state.nextCursor = nil
                owner.state.hasMore = true
                owner.fetchPostList(cursor: owner.state.nextCursor)
            }
            .store(in: &cancellables)
        
        input.cellWillDisplay
            .withUnretained(self)
            .sink(receiveValue: { (owner: StorePostViewModel, index: Int) in
                guard owner.canLoadMore(index: index) else { return }
                
                owner.fetchPostList(cursor: owner.state.nextCursor)
            })
            .store(in: &cancellables)
        
        input.didTapWrite
            .withUnretained(self)
            .sink(receiveValue: { (owner: StorePostViewModel, _) in
                owner.dependency.logManager.sendEvent(.init(
                    screen: owner.output.screenName,
                    eventName: .clickUploadPost
                ))
                let viewModel = owner.createUploadPostViewModel()
                
                owner.output.route.send(.pushUpload(viewModel: viewModel))
            })
            .store(in: &cancellables)
        
        input.didTapEdit
            .withUnretained(self)
            .sink(receiveValue: { (owner: StorePostViewModel, postId: String) in
                guard let cellViewModel = owner.output.postCellViewModelList.value.first(where: {
                    $0.output.storePost.postId == postId
                }) else { return }
                
                let viewModel = owner.createUploadPostViewModel(post: cellViewModel.output.storePost)
                
                owner.output.route.send(.pushEdit(viewModel: viewModel))
            })
            .store(in: &cancellables)
        
        input.didTapDelete
            .withUnretained(self)
            .sink(receiveValue: { (owner: StorePostViewModel, postId: String) in
                guard let index = owner.output.postCellViewModelList.value.firstIndex(where: {
                    $0.output.storePost.postId == postId
                }) else { return }
                
                owner.deletePost(index: index)
            })
            .store(in: &cancellables)
    }
    
    private func fetchPostList(cursor: String?) {
        Task { [weak self] in
            guard let self else { return }
            let storeId = dependency.userDefaults.storeId
            let result = await dependency.storePostRepository.fetchPostList(storeId: storeId, cursor: cursor)
            
            switch result {
            case .success(let response):
                if cursor.isNil {
                    let cellViewModelList = response.contents.compactMap { [weak self] in
                        return self?.createPostCellViewModel(from: $0)
                    }
                    output.postCellViewModelList.send(cellViewModelList)
                    
                } else {
                    let newCellViewModelList = response.contents.compactMap { [weak self] in
                        return self?.createPostCellViewModel(from: $0)
                    }
                    let cellViewModelList = output.postCellViewModelList.value + newCellViewModelList
                    output.postCellViewModelList.send(cellViewModelList)
                }
                state.nextCursor = response.cursor.nextCursor
                state.hasMore = response.cursor.hasMore
            case .failure(let error):
                output.route.send(.showErrorAlert(error: error))
            }
        }
    }
    
    private func createPostCellViewModel(from storePost: StorePostApiResponse) -> StorePostCellViewModel {
        let viewModel = StorePostCellViewModel(storePost: storePost)
        
        viewModel.output.didTapEdit
            .subscribe(input.didTapEdit)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.didTapDelete
            .subscribe(input.didTapDelete)
            .store(in: &viewModel.cancellables)
        return viewModel
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return state.hasMore && state.nextCursor.isNotNil && index >= output.postCellViewModelList.value.count - 1
    }
    
    private func deletePost(index: Int) {
        guard let post = output.postCellViewModelList.value[safe: index]?.output.storePost else { return }
        
        Task {
            let storeId = dependency.userDefaults.storeId
            let result = await dependency.storePostRepository.deletePost(storeId: storeId, postId: post.postId)
            
            switch result {
            case .success:
                var postList = output.postCellViewModelList.value
                postList.remove(at: index)
                output.postCellViewModelList.send(postList)
            case .failure(let error):
                output.route.send(.showErrorAlert(error: error))
            }
        }
    }
    
    private func createUploadPostViewModel(post: StorePostApiResponse? = nil) -> UploadPostViewModel {
        let config = UploadPostViewModel.Config(storePostApiResponse: post)
        let viewModel = UploadPostViewModel(config: config)
        viewModel.output.onCreatedPost
            .subscribe(input.firstLoad)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onEditedPost
            .withUnretained(self)
            .sink(receiveValue: { (owner: StorePostViewModel, post: StorePostApiResponse) in
                if let targetIndex = owner.output.postCellViewModelList.value.firstIndex(where: { $0.output.storePost.postId == post.postId }) {
                    let postList = owner.output.postCellViewModelList.value
                    postList[targetIndex].output.storePost = post
                    owner.output.postCellViewModelList.send(postList)
                }
            })
            .store(in: &viewModel.cancellables)
        return viewModel
    }
}
