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
        case pushUpload
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
                self?.route.send(.pushUpload)
            }
            .store(in: &cancellables)
    }
    
    private func fetchPostList(cursor: String?) {
        Task { [weak self] in
            guard let self else { return }
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
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return state.hasMore && state.nextCursor.isNotNil && index >= postList.count - 1
    }
}
