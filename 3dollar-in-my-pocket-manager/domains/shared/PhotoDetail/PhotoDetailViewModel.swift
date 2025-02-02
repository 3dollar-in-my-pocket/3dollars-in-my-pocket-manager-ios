import Combine

extension PhotoDetailViewModel {
    struct Input {
        let didTapPrevious = PassthroughSubject<Void, Never>()
        let didTapNext = PassthroughSubject<Void, Never>()
        let didScroll = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let images: [ImageResponse]
        let currentIndex: CurrentValueSubject<Int, Never>
        let scrollToIndex: CurrentValueSubject<Int, Never>
        let isHiddenPrevious: CurrentValueSubject<Bool, Never>
        let isHiddenNext: CurrentValueSubject<Bool, Never>
    }
    
    struct Config {
        let images: [ImageResponse]
        let currentIndex: Int
    }
}

final class PhotoDetailViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(
            images: config.images,
            currentIndex: .init(config.currentIndex),
            scrollToIndex: .init(config.currentIndex),
            isHiddenPrevious: .init(config.currentIndex == 0),
            isHiddenNext: .init(config.currentIndex == config.images.count - 1)
        )
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapPrevious
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, _) in
                let previousIndex = max(owner.output.currentIndex.value - 1, 0)
                
                if previousIndex == 0 {
                    owner.output.isHiddenPrevious.send(true)
                }
                owner.output.isHiddenNext.send(false)
                owner.output.scrollToIndex.send(previousIndex)
                owner.output.currentIndex.send(previousIndex)
            }
            .store(in: &cancellables)
        
        input.didTapNext
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, _) in
                let nextIndex = min(owner.output.currentIndex.value + 1, owner.output.images.count - 1)
                
                if nextIndex == owner.output.images.count - 1 {
                    owner.output.isHiddenNext.send(true)
                }
                owner.output.isHiddenPrevious.send(false)
                owner.output.scrollToIndex.send(nextIndex)
                owner.output.currentIndex.send(nextIndex)
            }
            .store(in: &cancellables)

        input.didScroll
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, index: Int) in
                if index == 0 {
                    owner.output.isHiddenPrevious.send(true)
                    owner.output.isHiddenNext.send(false)
                }
                
                if index == owner.output.images.count - 1 {
                    owner.output.isHiddenPrevious.send(false)
                    owner.output.isHiddenNext.send(true)
                }
                
                owner.output.currentIndex.send(index)
            }
            .store(in: &cancellables)
    }
}
