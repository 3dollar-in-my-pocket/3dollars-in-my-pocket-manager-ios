import Combine
import SwiftUI

extension StorePostViewModel {
    struct Dependency {
        let storePostRepository: StorePostRepository
        var userDefaults: UserDefaultsUtils
        
        init(
            storePostRepository: StorePostRepository = StorePostRepositoryImpl(),
            userDefaults: UserDefaultsUtils = UserDefaultsUtils()
        ) {
            self.storePostRepository = storePostRepository
            self.userDefaults = userDefaults
        }
    }
    
    struct State {
        var hasMore = true
        var nextCursor: String? = nil
    }
    
    enum Route {
        case pushUpload(viewModel: UploadPostViewModel)
        case pushEdit(viewModel: UploadPostViewModel)
    }
}

@MainActor
final class StorePostViewModel: ObservableObject {
    // MARK: Input
    let onAppear = PassthroughSubject<Void, Never>()
    let cellWillDisplay = PassthroughSubject<Int, Never>()
    let didTapEdit = PassthroughSubject<Int, Never>()
    let didTapDelete = PassthroughSubject<Int, Never>()
    let didTapWrite = PassthroughSubject<Void, Never>()
    
    // MARK: Output
    @Published var postList: [StorePostApiResponse] = []
    @Published var isLoading = false
    let route = PassthroughSubject<Route, Never>()
    
    
    private var state = State()
    private let dependency: Dependency
    private var cancellables = Set<AnyCancellable>()
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        bind()
    }
    
    private func bind() {
        onAppear.sink { [weak self] _ in
            guard let self else { return }
            state.nextCursor = nil
            state.hasMore = true
            fetchPostList(cursor: state.nextCursor)
        }
        .store(in: &cancellables)
        
        cellWillDisplay
            .sink { [weak self] index in
                guard let self, canLoadMore(index: index) else { return }
                
                fetchPostList(cursor: state.nextCursor)
            }
            .store(in: &cancellables)
        
        didTapWrite
            .sink { [weak self] _ in
                let viewModel = UploadPostViewModel()
                viewModel.output.onCreatedPost
                    .sink { [weak self] _ in
                        self?.onAppear.send(())
                    }
                    .store(in: &viewModel.cancellables)
                self?.route.send(.pushUpload(viewModel: viewModel))
            }
            .store(in: &cancellables)
        
        didTapEdit
            .sink { [weak self] index in
                guard let self, let post = postList[safe: index] else { return }
                let config = UploadPostViewModel.Config(storePostApiResponse: post)
                let viewModel = UploadPostViewModel(config: config)
                
                route.send(.pushEdit(viewModel: viewModel))
            }
            .store(in: &cancellables)
        
        didTapDelete
            .sink { [weak self] index in
                self?.deletePost(index: index)
            }
            .store(in: &cancellables)
    }
    
    private func fetchPostList(cursor: String?) {
        Task { [weak self] in
            guard let self else { return }
            isLoading = true
            let storeId = dependency.userDefaults.storeId
            let result = await dependency.storePostRepository.fetchPostList(storeId: storeId, cursor: cursor)
            
            switch result {
            case .success(let response):
                state.nextCursor = response.cursor.nextCursor
                state.hasMore = response.cursor.hasMore
                postList.append(contentsOf: response.contents)
            case .failure(let error):
                print("🟢error: \(error)")
            }
            isLoading = false
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return state.hasMore && state.nextCursor.isNotNil && index >= postList.count - 1
    }
    
    private func deletePost(index: Int) {
        guard let post = postList[safe: index] else { return }
        
        Task {
            let storeId = dependency.userDefaults.storeId
            let result = await dependency.storePostRepository.deletePost(storeId: storeId, postId: post.postId)
            
            switch result {
            case .success:
                postList.remove(at: index)
            case .failure(let error):
                print("🟢error: \(error)")
            }
        }
    }
}
