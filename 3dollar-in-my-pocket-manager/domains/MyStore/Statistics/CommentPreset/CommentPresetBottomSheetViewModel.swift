import Combine

extension CommentPresetBottomSheetViewModel {
    struct Input {
        let didTapPreset = PassthroughSubject<Int, Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
        let didTapEditPreset = PassthroughSubject<Int, Never>()
        let didTapDeletePreset = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        var dataSource: [CommentPresetResponse]
        let didTapPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
        let didTapEditPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapDeletePreset = PassthroughSubject<CommentPresetResponse, Never>()
    }
    
    struct Config {
        var presets: [CommentPresetResponse] = []
    }
}

final class CommentPresetBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    
    init(config: Config) {
        self.output = Output(dataSource: config.presets)
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapPreset
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheetViewModel, index: Int) in
                guard let preset = owner.output.dataSource[safe: index] else { return }
                
                owner.output.didTapPreset.send(preset)
            }
            .store(in: &cancellables)
        
        input.didTapAddPreset
            .subscribe(output.didTapAddPreset)
            .store(in: &cancellables)
        
        input.didTapEditPreset
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheetViewModel, index: Int) in
                guard let preset = owner.output.dataSource[safe: index] else { return }
                
                owner.output.didTapEditPreset.send(preset)
            }
            .store(in: &cancellables)
        
        input.didTapDeletePreset
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheetViewModel, index: Int) in
                guard let preset = owner.output.dataSource[safe: index] else { return }
                
                owner.output.didTapDeletePreset.send(preset)
            }
            .store(in: &cancellables)
    }
}
