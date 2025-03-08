import Combine

extension CommentPresetCellViewModel {
    struct Input {
        let didTapDelete = PassthroughSubject<Void, Never>()
        let didTapEdit = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let preset: CommentPresetResponse
        let didTapDelete = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapEdit = PassthroughSubject<CommentPresetResponse, Never>()
    }
    
    struct Config {
        let preset: CommentPresetResponse
    }
}

final class CommentPresetCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(preset: config.preset)
        super.init()
        
        bind()
    }

    private func bind() {
        input.didTapDelete
            .withUnretained(self)
            .sink(receiveValue: { (owner: CommentPresetCellViewModel, _) in
                owner.output.didTapDelete.send(owner.output.preset)
            })
            .store(in: &cancellables)
        
        input.didTapEdit
            .withUnretained(self)
            .sink(receiveValue: { (owner: CommentPresetCellViewModel, _) in
                owner.output.didTapEdit.send(owner.output.preset)
            })
            .store(in: &cancellables)
    }
}
