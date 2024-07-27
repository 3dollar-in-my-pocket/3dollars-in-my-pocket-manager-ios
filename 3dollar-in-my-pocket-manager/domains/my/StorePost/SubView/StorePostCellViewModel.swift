import Foundation
import Combine

extension StorePostCellViewModel {
    struct Input {
        let didTapEdit = PassthroughSubject<Void, Never>()
        let didTapDelete = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var storePost: StorePostApiResponse
        let didTapEdit = PassthroughSubject<String, Never>()
        let didTapDelete = PassthroughSubject<String, Never>()
    }
}

final class StorePostCellViewModel {
    let input = Input()
    var output: Output
    var cancellables = Set<AnyCancellable>()
    
    init(storePost: StorePostApiResponse) {
        self.output = Output(storePost: storePost)
        
        bind()
    }
    
    private func bind() {
        input.didTapEdit
            .withUnretained(self)
            .map { (owner: StorePostCellViewModel, _) in
                owner.output.storePost.postId
            }
            .subscribe(output.didTapEdit)
            .store(in: &cancellables)
        
        input.didTapDelete
            .withUnretained(self)
            .map { (owner: StorePostCellViewModel, _) in
                owner.output.storePost.postId
            }
            .subscribe(output.didTapDelete)
            .store(in: &cancellables)
    }
}
